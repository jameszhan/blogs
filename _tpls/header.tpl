---
    group: templates
---
{% strip %}
<div class="container">
    <div class="navbar-header">
        <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".bs-navbar-collapse">
            <span class="sr-only">{{ site.title }}</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
        </button>
        <a href="{{ site.baseurl }}/" class="navbar-brand">{{ site.title }}</a>
    </div>
    <nav class="collapse navbar-collapse bs-navbar-collapse" role="navigation">
        <ul class="nav navbar-nav">
        {% assign sorted_pages = site.pages | sort: 'weight' %}
        {% for page in sorted_pages %}
            {% if page.title and page.name contains ".html" and page.group != 'popup' %}
            <li><a class="page-link" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a></li>
            {% endif %}
        {% endfor %}
        </ul>
        <ul class="nav navbar-nav navbar-right">
        {% assign docs = site.collections['sitemap'].docs %}
        {% for doc in docs %}
            {% if doc.title %}
            <li><a class="page-link" href="{{ doc.url | prepend: site.baseurl }}">{{ doc.title }}</a></li>
            {% endif %}
        {% endfor %}
            <li><a class="page-link" href="https://github.com/jameszhan">GitHub</a></li>
        </ul>
    </nav>
</div>
{% endstrip %}
