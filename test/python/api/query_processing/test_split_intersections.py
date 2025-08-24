# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of Nominatim. (https://nominatim.org)
#
# Copyright (C) 2025 by the Nominatim developer community.
# For a full list of authors see the git log.
"""Tests for intersection phrase splitting."""
import pytest

import nominatim_api.search.query as qmod
from nominatim_api.query_preprocessing.config import QueryConfig
from nominatim_api.query_preprocessing import intersection_split


def run_preprocessor_on(query):
    proc = intersection_split.create(QueryConfig().set_normalizer(None))
    return proc(query)


@pytest.mark.parametrize('inp,outp', [
    ('Main St and First Ave', 'Main St:First Ave'),  # English 'and'
    ('Pine St with 2nd Ave', 'Pine St:2nd Ave'),  # English 'with'
    ('Oak St & Elm St', 'Oak St:Elm St'),  # ampersand
    ("Rue de Lyon / Rue d'Alésia", "Rue de Lyon:Rue d'Alésia"),  # slash
    ('Avenida de Mayo con Calle Florida', 'Avenida de Mayo:Calle Florida'),  # Spanish 'con'
    ('Gran Via y Calle de Alcalá', 'Gran Via:Calle de Alcalá'),  # Spanish 'y'
    ("Rue de Rivoli et Avenue de l'Opéra", "Rue de Rivoli:Avenue de l'Opéra"),  # French 'et'
    ('Via Roma e Via Milano', 'Via Roma:Via Milano'),  # Italian/Portuguese 'e'
    ('Hauptstraße und Bahnhofstraße', 'Hauptstraße:Bahnhofstraße'),  # German 'und'
    (
        'Kurfürstendamm ecke Joachimsthaler Straße',
        'Kurfürstendamm:Joachimsthaler Straße',
    ),  # German 'ecke'
])
def test_split_phrases(inp, outp):
    query = [qmod.Phrase(qmod.PHRASE_ANY, inp)]
    out = run_preprocessor_on(query)
    assert out == [qmod.Phrase(qmod.PHRASE_INTERSECTION, outp)]


def test_no_split():
    query = [qmod.Phrase(qmod.PHRASE_ANY, 'Foo Street')]
    out = run_preprocessor_on(query)
    assert out == query
