-- Generates the count of occurrences on each classification lineage.
--
-- This template uses the following parameters
--   {{occurrence}} table
--   {{checklistKey}} for the taxonomy

WITH base AS (
  SELECT classificationDetails['{{checklistKey}}'] AS c
  FROM {{occurrence}}
),

taxonomy AS (
  SELECT
    filter(
      array(
        -- this is expected to be relatively static but an enum or runtime API may be suitable if not
        named_struct('rank','domain',                 'id', c['domainkey'],                 'name', c['domain']),
        named_struct('rank','realm',                  'id', c['realmkey'],                  'name', c['realm']),
        named_struct('rank','kingdom',                'id', c['kingdomkey'],                'name', c['kingdom']),
        named_struct('rank','subkingdom',             'id', c['subkingdomkey'],             'name', c['subkingdom']),
        named_struct('rank','infrakingdom',           'id', c['infrakingdomkey'],           'name', c['infrakingdom']),
        named_struct('rank','phylum',                 'id', c['phylumkey'],                 'name', c['phylum']),
        named_struct('rank','subphylum',              'id', c['subphylumkey'],              'name', c['subphylum']),
        named_struct('rank','infraphylum',            'id', c['infraphylumkey'],            'name', c['infraphylum']),
        named_struct('rank','parvphylum',             'id', c['parvphylumkey'],             'name', c['parvphylum']),
        named_struct('rank','gigaclass',              'id', c['gigaclasskey'],              'name', c['gigaclass']),
        named_struct('rank','megaclass',              'id', c['megaclasskey'],              'name', c['megaclass']),
        named_struct('rank','superclass',             'id', c['superclasskey'],             'name', c['superclass']),
        named_struct('rank','class',                  'id', c['classkey'],                  'name', c['class']),
        named_struct('rank','subclass',               'id', c['subclasskey'],               'name', c['subclass']),
        named_struct('rank','infraclass',             'id', c['infraclasskey'],             'name', c['infraclass']),
        named_struct('rank','subterclass',            'id', c['subterclasskey'],            'name', c['subterclass']),
        named_struct('rank','superorder',             'id', c['superorderkey'],             'name', c['superorder']),
        named_struct('rank','order',                  'id', c['orderkey'],                  'name', c['order']),
        named_struct('rank','nanorder',               'id', c['nanorderkey'],               'name', c['nanorder']),
        named_struct('rank','suborder',               'id', c['suborderkey'],               'name', c['suborder']),
        named_struct('rank','infraorder',             'id', c['infraorderkey'],             'name', c['infraorder']),
        named_struct('rank','parvorder',              'id', c['parvorderkey'],              'name', c['parvorder']),
        named_struct('rank','section_zoology',        'id', c['section_zoologykey'],        'name', c['section_zoology']),
        named_struct('rank','subsection_zoology',     'id', c['subsection_zoologykey'],     'name', c['subsection_zoology']),
        named_struct('rank','superfamily',            'id', c['superfamilykey'],            'name', c['superfamily']),
        named_struct('rank','epifamily',              'id', c['epifamilykey'],              'name', c['epifamily']),
        named_struct('rank','family',                 'id', c['familykey'],                 'name', c['family']),
        named_struct('rank','subfamily',              'id', c['subfamilykey'],              'name', c['subfamily']),
        named_struct('rank','infrafamily',            'id', c['infrafamilykey'],            'name', c['infrafamily']),
        named_struct('rank','supertribe',             'id', c['supertribekey'],             'name', c['supertribe']),
        named_struct('rank','tribe',                  'id', c['tribekey'],                  'name', c['tribe']),
        named_struct('rank','subtribe',               'id', c['subtribekey'],               'name', c['subtribe']),
        named_struct('rank','infratribe',             'id', c['infratribekey'],             'name', c['infratribe']),
        named_struct('rank','genus',                  'id', c['genuskey'],                  'name', c['genus']),
        named_struct('rank','subgenus',               'id', c['subgenuskey'],               'name', c['subgenus']),
        named_struct('rank','section_botany',         'id', c['section_botanykey'],         'name', c['section_botany']),
        named_struct('rank','subsection_botany',      'id', c['subsection_botanykey'],      'name', c['subsection_botany']),
        named_struct('rank','series_botany',          'id', c['series_botanykey'],          'name', c['series_botany']),
        named_struct('rank','infrageneric_name',      'id', c['infrageneric_namekey'],      'name', c['infrageneric_name']),
        named_struct('rank','species_aggregate',      'id', c['species_aggregatekey'],      'name', c['species_aggregate']),
        named_struct('rank','species',                'id', c['specieskey'],                'name', c['species']),
        named_struct('rank','infraspecific_name',     'id', c['infraspecific_namekey'],     'name', c['infraspecific_name']),
        named_struct('rank','subspecies',             'id', c['subspecieskey'],             'name', c['subspecies']),
        named_struct('rank','infrasubspecific_name',  'id', c['infrasubspecific_namekey'],  'name', c['infrasubspecific_name']),
        named_struct('rank','proles',                 'id', c['proleskey'],                 'name', c['proles']),
        named_struct('rank','natio',                  'id', c['natiokey'],                  'name', c['natio']),
        named_struct('rank','aberration',             'id', c['aberrationkey'],             'name', c['aberration']),
        named_struct('rank','morph',                  'id', c['morphkey'],                  'name', c['morph']),
        named_struct('rank','variety',                'id', c['varietykey'],                'name', c['variety']),
        named_struct('rank','subvariety',             'id', c['subvarietykey'],             'name', c['subvariety']),
        named_struct('rank','form',                   'id', c['formkey'],                   'name', c['form']),
        named_struct('rank','subform',                'id', c['subformkey'],                'name', c['subform']),
        named_struct('rank','forma_specialis',        'id', c['forma_specialiskey'],        'name', c['forma_specialis']),
        named_struct('rank','lusus',                  'id', c['lususkey'],                  'name', c['lusus']),
        named_struct('rank','mutatio',                'id', c['mutatiokey'],                'name', c['mutatio'])      ),
      x -> x.id IS NOT NULL AND x.id != ''
    ) AS lineage
  FROM base
)

SELECT
  lineage,
  COUNT(*) AS occCount
FROM taxonomy
GROUP BY lineage