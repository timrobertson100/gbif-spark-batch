-- Generates the basic summary counts.
--
-- This template uses the following parameters
--   {{occurrence}} table
--   {{checklistKey}} for the taxonomy
--   {{topNDataset}} for the number of datasets to return

WITH taxon_metrics AS (
  SELECT
    taxonKey,
    count(*) AS totalCount,
    count_if(speciesKey IS NOT NULL) AS identifiedToSpeciesCount,
    count_if(decimalLatitude IS NOT NULL AND decimalLongitude IS NOT NULL) AS hasCoordinatesCount,
    count_if(year IS NOT NULL) AS hasYearCount,
    count_if(recordedBy IS NOT NULL AND recordedByID IS NOT NULL) AS hasRecorderCount,
    count_if(isSequenced = true) AS isSequencedCount,
    count_if(mediaType IS NOT NULL AND size(mediaType) > 0) AS hasMediaCount
  FROM {{occurrence}}
  GROUP BY taxonKey
),

month_counts AS (
  SELECT taxonKey, collect_list(struct(month, cnt)) AS monthCounts
  FROM (
    SELECT taxonKey, month, count(*) AS cnt
   FROM {{occurrence}}
    GROUP BY taxonKey, month
  ) m
  GROUP BY taxonKey
),

bor_counts AS (
  SELECT taxonKey, collect_list(struct(basisOfRecord,cnt)) AS basisOfRecordCounts
  FROM (
    SELECT taxonKey, basisOfRecord, count(*) AS cnt
   FROM {{occurrence}}
    GROUP BY taxonKey, basisOfRecord
  ) b
  GROUP BY taxonKey
),

country_counts AS (
  SELECT taxonKey, collect_list(struct(countryCode,cnt)) AS countryCounts
  FROM (
    SELECT taxonKey, countryCode, count(*) AS cnt
   FROM {{occurrence}}
    GROUP BY taxonKey, countryCode
  ) c
  GROUP BY taxonKey
),

-- top N datasets
dataset_counts AS (
  SELECT taxonKey, collect_list(struct(datasetKey, datasetTitle, cnt)) AS datasetCounts
  FROM (
    SELECT taxonKey, datasetKey, datasetTitle, cnt
    FROM (
      SELECT
        taxonKey,
        datasetKey,
        datasetTitle,
        COUNT(*) AS cnt,
        ROW_NUMBER() OVER (
          PARTITION BY taxonKey
          ORDER BY COUNT(*) DESC
        ) AS rn
     FROM {{occurrence}}
      GROUP BY taxonKey, datasetKey, datasetTitle
    ) t
    WHERE rn <= {{topNDataset}}
  ) d
  GROUP BY taxonKey
)

SELECT *
FROM taxon_metrics
  LEFT JOIN month_counts USING (taxonKey)
  LEFT JOIN bor_counts USING (taxonKey)
  LEFT JOIN country_counts USING (taxonKey)
  LEFT JOIN dataset_counts USING (taxonKey)