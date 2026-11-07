{# Custom schema name generator to mirror Databricks Unity Catalog schemas #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {# Keep cleanly named schemas: bronze, silver, gold #}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

