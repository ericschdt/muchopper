import shlex

import sqlalchemy

from . import model


def base_filter(q, include_closed=False):
    if not include_closed:
        q = q.filter(
            model.MUC.is_open == True  # NOQA
        )

    return q.filter(
        model.MUC.is_hidden == False  # NOQA
    )


def base_query(session, *,
               include_closed=False,
               with_avatar_flag=False):
    if with_avatar_flag:
        q = session.query(
            model.MUC,
            model.PubliclyListedMUC,
            model.Avatar.address != None,  # NOQA
        ).join(
            model.PubliclyListedMUC,
        ).outerjoin(
            model.Avatar,
        )
    else:
        q = session.query(
            model.MUC,
            model.PubliclyListedMUC
        ).join(
            model.PubliclyListedMUC
        )

    return base_filter(q, include_closed=include_closed)


def common_query(session, *,
                 min_users=1,
                 **kwargs):
    q = base_query(session, **kwargs)

    if min_users > 0:
        q = q.filter(
            model.MUC.nusers_moving_average > min_users
        )

    return q.order_by(
        model.MUC.nusers_moving_average.desc(),
        model.MUC.address.asc(),
    )


def chain_condition(conditional, new):
    if conditional is None:
        return new
    return sqlalchemy.or_(conditional, new)


def filter_keywords(keywords, min_length):
    keywords = set(
        keyword
        for keyword in (
            keyword.strip()
            for keyword in keywords
        )
        if len(keyword) >= min_length
    )
    return keywords


def prepare_keywords(query_string, min_length=3):
    keywords = shlex.split(query_string)
    return filter_keywords(keywords, min_length)


def apply_search_conditions(q,
                            keywords,
                            search_address,
                            search_description,
                            search_name):
    for keyword in keywords:
        conditional = None
        if search_address:
            conditional = chain_condition(
                conditional,
                model.PubliclyListedMUC.address.ilike("%" + keyword + "%")
            )
        if search_description:
            conditional = chain_condition(
                conditional,
                model.PubliclyListedMUC.description.ilike("%" + keyword + "%")
            )
        if search_name:
            conditional = chain_condition(
                conditional,
                model.PubliclyListedMUC.name.ilike("%" + keyword + "%")
            )
        q = q.filter(conditional)

    return q
