---
group: templates
---
{% strip %}
<div class="box">
    <h2 class="title">
        <span class="icon-text"><i class="glyphicon glyphicon-tags"></i>
            <a href="/tags/index.html">标签</a>
        </span>
    </h2>
    <ul class="list-inline">
        {% assign tags = site.tags %}
        {% include tags %}
    </ul>
</div>
{% endstrip %}