-- This will generate the top N records per taxon for all lower ranks.
--
WITH taxonomy AS (
  SELECT
    filter(
      array(
        named_struct('rank','domain',                 'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['domainkey'],                 'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['domain']),
        named_struct('rank','realm',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['realmkey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['realm']),
        named_struct('rank','kingdom',                'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['kingdomkey'],                'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['kingdom']),
        named_struct('rank','subkingdom',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subkingdomkey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subkingdom']),
        named_struct('rank','infrakingdom',           'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrakingdomkey'],           'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrakingdom']),
        named_struct('rank','phylum',                 'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['phylumkey'],                 'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['phylum']),
        named_struct('rank','subphylum',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subphylumkey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subphylum']),
        named_struct('rank','infraphylum',            'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraphylumkey'],            'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraphylum']),
        named_struct('rank','parvphylum',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['parvphylumkey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['parvphylum']),
        named_struct('rank','gigaclass',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['gigaclasskey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['gigaclass']),
        named_struct('rank','megaclass',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['megaclasskey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['megaclass']),
        named_struct('rank','superclass',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superclasskey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superclass']),
        named_struct('rank','class',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['classkey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['class']),
        named_struct('rank','subclass',               'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subclasskey'],               'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subclass']),
        named_struct('rank','infraclass',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraclasskey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraclass']),
        named_struct('rank','subterclass',            'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subterclasskey'],            'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subterclass']),
        named_struct('rank','superorder',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superorderkey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superorder']),
        named_struct('rank','order',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['orderkey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['order']),
        named_struct('rank','nanorder',               'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['nanorderkey'],               'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['nanorder']),
        named_struct('rank','suborder',               'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['suborderkey'],               'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['suborder']),
        named_struct('rank','infraorder',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraorderkey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraorder']),
        named_struct('rank','parvorder',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['parvorderkey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['parvorder']),
        named_struct('rank','section_zoology',        'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['section_zoologykey'],        'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['section_zoology']),
        named_struct('rank','subsection_zoology',     'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subsection_zoologykey'],     'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subsection_zoology']),
        named_struct('rank','superfamily',            'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superfamilykey'],            'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['superfamily']),
        named_struct('rank','epifamily',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['epifamilykey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['epifamily']),
        named_struct('rank','family',                 'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['familykey'],                 'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['family']),
        named_struct('rank','subfamily',              'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subfamilykey'],              'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subfamily']),
        named_struct('rank','infrafamily',            'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrafamilykey'],            'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrafamily']),
        named_struct('rank','supertribe',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['supertribekey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['supertribe']),
        named_struct('rank','tribe',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['tribekey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['tribe']),
        named_struct('rank','subtribe',               'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subtribekey'],               'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subtribe']),
        named_struct('rank','infratribe',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infratribekey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infratribe']),
        named_struct('rank','genus',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['genuskey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['genus']),
        named_struct('rank','subgenus',               'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subgenuskey'],               'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subgenus']),
        named_struct('rank','section_botany',         'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['section_botanykey'],         'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['section_botany']),
        named_struct('rank','subsection_botany',      'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subsection_botanykey'],      'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subsection_botany']),
        named_struct('rank','series_botany',          'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['series_botanykey'],          'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['series_botany']),
        named_struct('rank','infrageneric_name',      'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrageneric_namekey'],      'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrageneric_name']),
        named_struct('rank','species_aggregate',      'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['species_aggregatekey'],      'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['species_aggregate']),
        named_struct('rank','species',                'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['specieskey'],                'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['species']),
        named_struct('rank','infraspecific_name',     'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraspecific_namekey'],     'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infraspecific_name']),
        named_struct('rank','subspecies',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subspecieskey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subspecies']),
        named_struct('rank','infrasubspecific_name',  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrasubspecific_namekey'],  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['infrasubspecific_name']),
        named_struct('rank','proles',                 'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['proleskey'],                 'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['proles']),
        named_struct('rank','natio',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['natiokey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['natio']),
        named_struct('rank','aberration',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['aberrationkey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['aberration']),
        named_struct('rank','morph',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['morphkey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['morph']),
        named_struct('rank','variety',                'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['varietykey'],                'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['variety']),
        named_struct('rank','subvariety',             'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subvarietykey'],             'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subvariety']),
        named_struct('rank','form',                   'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['formkey'],                   'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['form']),
        named_struct('rank','subform',                'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subformkey'],                'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['subform']),
        named_struct('rank','forma_specialis',        'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['forma_specialiskey'],        'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['forma_specialis']),
        named_struct('rank','lusus',                  'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['lususkey'],                  'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['lusus']),
        named_struct('rank','mutatio',                'id', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['mutatiokey'],                'name', classificationDetails['7ddf754f-d193-4cc9-b351-99906754a03b']['mutatio'])
      ),
      x -> x.id IS NOT NULL AND x.id != ''
    ) AS lineage
  FROM prod_b.occurrence
),

edges AS (
  SELECT
    lineage[i].id AS parent_id,
    lineage[j].id AS child_id,
    lineage[j].rank AS child_rank,
    lineage[j].name AS child_name
  FROM taxonomy
  LATERAL VIEW posexplode(lineage) a AS i, a_struct
  LATERAL VIEW posexplode(lineage) b AS j, b_struct
  WHERE i < j
),

edge_counts AS (
  SELECT
    parent_id,
    child_id,
    child_rank,
    child_name,
    COUNT(*) AS occCount
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
  WHERE rn <= 101
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
GROUP BY parent_id;