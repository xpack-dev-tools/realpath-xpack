---

title: The xPack GNU realpath releases
permalink: /dev-tools/realpath/releases/

search: exclude
github_editme: false

comments: false
toc: false

date: 2022-10-04 10:32:00 +0300

redirect_to: https://xpack-dev-tools.github.io/realpath-xpack/docs/releases/

---

___
{% for post in site.posts %}{% if post.categories contains "releases" %}{% if post.categories contains "realpath" %}
* [{{ post.title }}]({{ site.baseurl }}{{ post.url }}) [(download)]({{ post.download_url }}){% endif %}{% endif %}{% endfor %}
