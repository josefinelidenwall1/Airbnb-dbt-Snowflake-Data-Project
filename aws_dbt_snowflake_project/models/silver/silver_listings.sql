{{ 
    config(
        materialized='incremental',
        unique_key='LISTING_ID' 
    )
}}

SELECT
    LISTING_ID,
    HOST_ID,
    PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    ACCOMMODATES,
    BEDROOMS,
    BATHROOMS,
    PRICE_PER_NIGHT,
    {{ tag('price_per_night') }} AS PRICE_PER_NIGHT_TAG,
    CREATED_AT
FROM
    {{ ref('bronze_listings')}}

{% if is_incremental() %}
    WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY LISTING_ID ORDER BY CREATED_AT DESC) = 1