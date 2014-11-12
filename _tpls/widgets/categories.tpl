---
group: templates
---
{% strip %}
<div class="box">
    <h2 class="title">
        <span class="icon-text"><i class="glyphicon glyphicon-tags"></i>
            <a href="/categories/index.html">分类</a></span>
    </h2>
    <ul class="list-inline">
        {% assign categories = site.categories %}
        {% include categories %}
    </ul>
</div>
{% endstrip %}