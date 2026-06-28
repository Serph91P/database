-- @operation: export
-- @entity: batch
-- @name: Add Not German guardrail to Max German profiles
-- @exportedAt: 2026-06-28T12:10:00.000Z
--
-- The Deutsch profiles must accept German-only releases and multi-language
-- releases that include German. English-only releases can still score highly
-- from quality/source tiers, so add an explicit language guardrail that only
-- matches releases without a German track.

-- Create a reusable language custom format: release has a non-German language
-- and does not include German. This bans English-only, but not German+English.
INSERT INTO custom_formats (name, description)
SELECT 'Not German', 'Matches releases that do not include a German language track. Multiple audio tracks are allowed when German is present.'
WHERE NOT EXISTS (
  SELECT 1 FROM custom_formats WHERE name = 'Not German'
);

UPDATE custom_formats
SET description = 'Matches releases that do not include a German language track. Multiple audio tracks are allowed when German is present.'
WHERE name = 'Not German';

INSERT INTO tags (name)
SELECT 'Language'
WHERE NOT EXISTS (
  SELECT 1 FROM tags WHERE name = 'Language'
);

INSERT INTO custom_format_tags (custom_format_name, tag_name)
SELECT 'Not German', 'Language'
WHERE NOT EXISTS (
  SELECT 1 FROM custom_format_tags
  WHERE custom_format_name = 'Not German'
    AND tag_name = 'Language'
);

DELETE FROM condition_languages
WHERE custom_format_name = 'Not German';

DELETE FROM custom_format_conditions
WHERE custom_format_name = 'Not German';

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Not German', 'Not German', 'language', 'all', 0, 1);

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language)
SELECT 'Not German', 'Not German', l.name, 1
FROM languages l
WHERE l.name = 'German';

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Not German', 'Includes German', 'language', 'all', 1, 1);

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language)
SELECT 'Not German', 'Includes German', l.name, 0
FROM languages l
WHERE l.name = 'German';

-- Apply the guardrail only to German-targeted profiles.
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT p.profile_name, 'Not German', 'all', -999999
FROM (
  SELECT 'Deutsch' AS profile_name
  UNION ALL SELECT 'Anime Deutsch'
) p
WHERE NOT EXISTS (
  SELECT 1 FROM quality_profile_custom_formats qpcf
  WHERE qpcf.quality_profile_name = p.profile_name
    AND qpcf.custom_format_name = 'Not German'
    AND qpcf.arr_type = 'all'
);

UPDATE quality_profile_custom_formats
SET score = -999999
WHERE quality_profile_name IN ('Deutsch', 'Anime Deutsch')
  AND custom_format_name = 'Not German'
  AND arr_type = 'all';
