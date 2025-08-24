# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of Nominatim. (https://nominatim.org)
#
# Copyright (C) 2025 by the Nominatim developer community.
# For a full list of authors see the git log.
"""Split street intersections from a single phrase.

This preprocessing step looks for connector words separating two street
names and rewrites the phrase so that it becomes an intersection of the
form ``streetA:streetB``.
"""
from typing import List
import re

from .config import QueryConfig
from .base import QueryProcessingFunc
from ..search.query import Phrase, PHRASE_INTERSECTION

# Match common words used to connect two street names.
# Supported connectors:
#   English: and, with, &, /
#   Spanish: con, y
#   French: et
#   Italian/Portuguese: e
#   German: und, ecke
CONNECTOR_PATTERN = re.compile(
    r"\s*(?:&|/|\b(?:and|with|con|y|et|e|und|ecke)\b)\s*",
    re.IGNORECASE,
)


class _IntersectionSplit:
    """Callable preprocessing step that rewrites intersection phrases."""

    def __init__(self, config: QueryConfig) -> None:
        self.config = config

    def split_phrase(self, phrase: Phrase) -> Phrase:
        parts = CONNECTOR_PATTERN.split(phrase.text)
        if len(parts) == 2 and all(parts):
            street_a = parts[0].strip()
            street_b = parts[1].strip()
            return Phrase(PHRASE_INTERSECTION, f"{street_a}:{street_b}")
        return phrase

    def __call__(self, phrases: List[Phrase]) -> List[Phrase]:
        return [self.split_phrase(p) for p in phrases]


def create(config: QueryConfig) -> QueryProcessingFunc:
    """Create a preprocessing callable for intersection splitting."""
    return _IntersectionSplit(config)
