
{% if config.google_adsense.enable %}
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<script>
  (adsbygoogle = window.adsbygoogle || []).push({
    google_ad_client: "{{ config.google_adsense.google_ad_client }}",
    enable_page_level_ads: true
  });
</script>
{% endif %}

