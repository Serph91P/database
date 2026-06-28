-- @operation: export
-- @entity: batch
-- @name: Fix Max German profile language overrides
-- @exportedAt: 2026-06-28T12:00:00.000Z
--
-- The Max language-specific profiles created in op 188 are derived from the
-- upstream base profiles. Those base profiles intentionally contain global
-- language guardrails like German DL and Not Original or English at -999999.
-- For the German variants those guardrails are counterproductive: German DL
-- releases are exactly what the profile should accept, and the English/Original
-- guardrail can reject German releases after the profile language is switched.
--
-- Also normalize the profile language rows to the current v2 shape: one
-- language row with type = simple. Earlier import rows used type = must, but
-- later upstream ops migrated quality-profile language selection to simple.

-- Normalize language selection for all six Max variants.
DELETE FROM quality_profile_languages
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Deutsch', l.name, 'simple' FROM languages l WHERE l.name = 'German';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Englisch', l.name, 'simple' FROM languages l WHERE l.name = 'English';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Original', l.name, 'simple' FROM languages l WHERE l.name = 'Original';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Deutsch', l.name, 'simple' FROM languages l WHERE l.name = 'German';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Englisch', l.name, 'simple' FROM languages l WHERE l.name = 'English';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Original', l.name, 'simple' FROM languages l WHERE l.name = 'Original';

-- Remove inherited bans that are wrong for German-targeted profiles.
DELETE FROM quality_profile_custom_formats
WHERE quality_profile_name IN ('Deutsch', 'Anime Deutsch')
  AND custom_format_name IN ('German DL', 'Not Original', 'Not Original or English')
  AND score = -999999;
