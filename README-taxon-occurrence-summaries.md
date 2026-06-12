## Taxon Occurrence Summaries

Processes occurrence data and generates metrics in HBase for rendering taxon pages. 

The output is a set of HFiles suitable for bulk loading into HBase.

Build the project: `mvn spotless:apply test package`

To generate a new table:

Setup hbase:
```
disable 'taxon_occurrence_summary'
drop 'taxon_occurrence_summary'
create 'taxon_occurrence_summary',
  {NAME => 'o', VERSIONS => 1, COMPRESSION => 'SNAPPY', DATA_BLOCK_ENCODING => 'FAST_DIFF', BLOOMFILTER => 'ROW', TTL => 15552000},
  {NUMREGIONS => 10, SPLITALGO => 'HexStringSplit'}
```
