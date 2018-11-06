{% macro closed_marker() %}
{{ '  ' }}<span class="closed-marker" title="This room requires a password or invitation.">🔒</span>
{% endmacro %}
{% macro nonanon_marker() %}
{{ '  ' }}<abbr title="This room is not anonymous; other occupants may be able to see your address.">⏿</abbr>
{% endmacro %}

{% macro room_label(muc, public_info, keywords=[]) -%}
{%- if public_info.name and public_info.description and public_info.name != public_info.description and public_info.name != muc.address.localpart -%}
<span class="name">{{ public_info.name | highlight(keywords) }}</span><span class="address-suffix"> ({{ muc.address | highlight(keywords) }})</span>
{%- else -%}
{%- if muc.address.localpart -%}
<span class="address"><span class="localpart">{{ muc.address.localpart | highlight(keywords) }}</span><span class="at">@</span><span class="domain">{{ muc.address.domain | highlight(keywords) }}</span></span>
{%- else -%}
{{ muc.address | highlight(keywords) }}
{%- endif -%}
{%- endif -%}
{%- endmacro %}

{% macro room_table(items, keywords=[], caller=None) %}
<table class="roomlist">
    <colgroup>
        <col class="nusers"/>
        <col class="label"/>
    </colgroup>
    <thead>
        <tr>
            <th class="nusers"><abbr title="Number of online users">#users<abbr></th>
            <th class="addr-descr">Address &amp; Description</th>
        </tr>
    </thead>
    <tbody>
        {% for muc, public_info in items %}
        <tr>
            <td class="nusers numeric">{{ "%.0f" | format((muc.nusers_moving_average or muc.nusers) | round) }}</td>
            <td class="addr-descr">
                <div class="addr"><a href="xmpp:{{ muc.address }}?join">{{ room_label(muc, public_info, keywords) }}</a>{% if not muc.is_open %}{{ closed_marker() }}{% endif %}{% if not muc.anonymity_mode or muc.anonymity_mode.value == "none" %}{{ nonanon_marker() }}{% endif %}</div>
                {% set descr = public_info.description or public_info.name or public_info.subject %}
                {% set show_descr = descr and descr != muc.address.localpart %}
                {% set show_lang = public_info.language %}
                {% if show_descr or show_lang %}
                <div class="descr">{% if show_descr %}<span class="descr">{{ descr | highlight(keywords) }}</span>{% endif %}{% if show_lang %}{% if show_descr %} {% endif %}<span class="language">{% if show_descr %}({% endif %}Primary language: {{ public_info.language | prettify_lang }}{% if show_descr %}){% endif %}</span>{% endif %}</div>
                {% endif %}
            </td>
        </tr>
        {% endfor %}
    </tbody>
</table>
{% endmacro %}
