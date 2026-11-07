{# A macro to convert cents to dollars with custom decimal places #}
{% macro cents_to_dollars(column_name, decimal_places=2) -%}
    round(cast({{ column_name }} as decimal(18, 2)) / 100.0, {{ decimal_places }})
{%- endmacro %}

