-- Generates the summary of top N occurring species for all descendant ranks.
--
-- This template uses the following parameters
--   {{occurrence}} table
--   {{topNTaxa}} for the number of taxa to return


WITH lineage AS (
  SELECT
    lineage,
    COUNT(*) AS occCount
  FROM {{occurrence}}
  GROUP BY lineage
),

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

ranked AS (
  SELECT *,
    row_number() OVER (
      PARTITION BY parent_id, child_rank
      ORDER BY occCount DESC
    ) AS rn
  FROM edge_counts
),

top_children AS (
  SELECT *
  FROM ranked
  WHERE rn <= {{topNTaxa}}
),

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

SELECT
  parent_id AS taxonKey,
  map_from_entries(
    collect_list(
      struct(child_rank, children)
    )
  ) AS childrenByRank
FROM by_rank
GROUP BY parent_id