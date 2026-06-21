-- Generates the summary of top N occurring species for all descendant ranks.
--
-- This template uses the following parameters
--   {{occurrence}} table
--   {{topNTaxa}} for the number of taxa to return

-- reduce billions to a few millions with a count
WITH lineage AS (
  SELECT
    lineage,
    COUNT(*) AS occCount
  FROM {{occurrence}}
  GROUP BY lineage
),

-- cross join to generate a direct edge to each descendant taxa
-- e.g. Animaila -> Chordata, Animalia -> Felidae, Animalia -> Puma concolor etc.
edges AS (
  SELECT
    parent.id AS parent_id,
    child.id AS child_id,
    child.rank AS child_rank,
    child.name AS child_name,
    occCount
  FROM lineage
  LATERAL VIEW posexplode(lineage) a AS i, parent
  LATERAL VIEW posexplode(lineage) b AS j, child
  WHERE i < j
),

-- occurrence counts per descendant taxon
edge_counts AS (
  SELECT
    parent_id,
    child_id,
    child_rank,
    child_name,
    SUM(occCount) AS occCount
  FROM edges
  GROUP BY parent_id, child_id, child_rank, child_name
),

-- ordered to select the most occurring taxa
ranked AS (
  SELECT *,
    row_number() OVER (
      PARTITION BY parent_id, child_rank
      ORDER BY occCount DESC
    ) AS rn
  FROM edge_counts
),

-- filter to the top occurrinug
top_children AS (
  SELECT *
  FROM ranked
  WHERE rn <= {{topNTaxa}}
),

-- group to a collection per descendant rank
by_rank AS (
  SELECT
    parent_id,
    child_rank,
    collect_list(
      named_struct(
        'taxonKey', child_id,
        'name', child_name,
        'occCount', occCount
      )
    ) AS children
  FROM top_children
  GROUP BY parent_id, child_rank
)

-- group to a single row for each taxon
SELECT
  parent_id AS taxonKey,
  map_from_entries(
    collect_list(
      struct(child_rank, children)
    )
  ) AS childrenByRank
FROM by_rank
GROUP BY parent_id