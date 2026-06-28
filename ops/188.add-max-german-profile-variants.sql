-- @operation: export
-- @entity: batch
-- @name: Add Max German and language-specific profile variants
-- @exportedAt: 2026-06-28T10:45:00.000Z
--
-- This keeps the Profilarr v2 database compatible with Max's former v1 setup:
-- - Deutsch, Englisch, Original based on 2160p Remux
-- - Anime Deutsch, Anime Englisch, Anime Original based on 1080p Quality
--
-- The op is intentionally idempotent. It replaces these six derived profiles
-- from their current upstream base profiles every time it is applied.

-- Remove existing derived profile data first.
DELETE FROM quality_profile_custom_formats
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_profile_languages
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_profile_tags
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_profile_qualities
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_group_members
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_groups
WHERE quality_profile_name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

DELETE FROM quality_profiles
WHERE name IN ('Deutsch', 'Englisch', 'Original', 'Anime Deutsch', 'Anime Englisch', 'Anime Original');

-- Base profile copies.
INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Deutsch', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '2160p Remux';

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Englisch', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '2160p Remux';

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Original', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '2160p Remux';

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Anime Deutsch', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '1080p Quality';

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Anime Englisch', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '1080p Quality';

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT 'Anime Original', description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '1080p Quality';

-- Copy quality groups and members.
INSERT INTO quality_groups (quality_profile_name, name)
SELECT target.target_name, source.name
FROM quality_groups source
JOIN (
  SELECT '2160p Remux' AS source_name, 'Deutsch' AS target_name
  UNION ALL SELECT '2160p Remux', 'Englisch'
  UNION ALL SELECT '2160p Remux', 'Original'
  UNION ALL SELECT '1080p Quality', 'Anime Deutsch'
  UNION ALL SELECT '1080p Quality', 'Anime Englisch'
  UNION ALL SELECT '1080p Quality', 'Anime Original'
) target ON source.quality_profile_name = target.source_name;

INSERT INTO quality_group_members (quality_profile_name, quality_group_name, quality_name, position)
SELECT target.target_name, source.quality_group_name, source.quality_name, source.position
FROM quality_group_members source
JOIN (
  SELECT '2160p Remux' AS source_name, 'Deutsch' AS target_name
  UNION ALL SELECT '2160p Remux', 'Englisch'
  UNION ALL SELECT '2160p Remux', 'Original'
  UNION ALL SELECT '1080p Quality', 'Anime Deutsch'
  UNION ALL SELECT '1080p Quality', 'Anime Englisch'
  UNION ALL SELECT '1080p Quality', 'Anime Original'
) target ON source.quality_profile_name = target.source_name;

INSERT INTO quality_profile_qualities (quality_profile_name, quality_name, quality_group_name, position, enabled, upgrade_until)
SELECT target.target_name, source.quality_name, source.quality_group_name, source.position, source.enabled, source.upgrade_until
FROM quality_profile_qualities source
JOIN (
  SELECT '2160p Remux' AS source_name, 'Deutsch' AS target_name
  UNION ALL SELECT '2160p Remux', 'Englisch'
  UNION ALL SELECT '2160p Remux', 'Original'
  UNION ALL SELECT '1080p Quality', 'Anime Deutsch'
  UNION ALL SELECT '1080p Quality', 'Anime Englisch'
  UNION ALL SELECT '1080p Quality', 'Anime Original'
) target ON source.quality_profile_name = target.source_name;

-- Copy profile tags and add Anime tag to the anime variants.
INSERT INTO quality_profile_tags (quality_profile_name, tag_name)
SELECT target.target_name, source.tag_name
FROM quality_profile_tags source
JOIN (
  SELECT '2160p Remux' AS source_name, 'Deutsch' AS target_name
  UNION ALL SELECT '2160p Remux', 'Englisch'
  UNION ALL SELECT '2160p Remux', 'Original'
  UNION ALL SELECT '1080p Quality', 'Anime Deutsch'
  UNION ALL SELECT '1080p Quality', 'Anime Englisch'
  UNION ALL SELECT '1080p Quality', 'Anime Original'
) target ON source.quality_profile_name = target.source_name;

INSERT INTO quality_profile_tags (quality_profile_name, tag_name)
SELECT profile_name, 'Anime'
FROM (
  SELECT 'Anime Deutsch' AS profile_name
  UNION ALL SELECT 'Anime Englisch'
  UNION ALL SELECT 'Anime Original'
) anime_profiles
WHERE NOT EXISTS (
  SELECT 1 FROM quality_profile_tags qpt
  WHERE qpt.quality_profile_name = anime_profiles.profile_name
    AND qpt.tag_name = 'Anime'
);

-- Language policy overrides.
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Deutsch', l.name, 'must' FROM languages l WHERE l.name = 'German';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Englisch', l.name, 'must' FROM languages l WHERE l.name = 'English';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Original', l.name, 'must' FROM languages l WHERE l.name = 'Original';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Deutsch', l.name, 'must' FROM languages l WHERE l.name = 'German';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Englisch', l.name, 'must' FROM languages l WHERE l.name = 'English';
INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
SELECT 'Anime Original', l.name, 'must' FROM languages l WHERE l.name = 'Original';

-- Copy existing custom-format scores from the source profiles.
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT target.target_name, source.custom_format_name, source.arr_type, source.score
FROM quality_profile_custom_formats source
JOIN (
  SELECT '2160p Remux' AS source_name, 'Deutsch' AS target_name
  UNION ALL SELECT '2160p Remux', 'Englisch'
  UNION ALL SELECT '2160p Remux', 'Original'
  UNION ALL SELECT '1080p Quality', 'Anime Deutsch'
  UNION ALL SELECT '1080p Quality', 'Anime Englisch'
  UNION ALL SELECT '1080p Quality', 'Anime Original'
) target ON source.quality_profile_name = target.source_name;

-- Add Max's former anime boosts to the anime variants.
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT p.profile_name, cf.name, 'all', p.score
FROM (
  SELECT 'Anime Deutsch' AS profile_name, 'Anime Bluray Tier 1' AS cf_name, 125000 AS score
  UNION ALL SELECT 'Anime Deutsch', 'Anime Bluray Tier 2', 124000
  UNION ALL SELECT 'Anime Deutsch', 'Anime Bluray Tier 3', 123000
  UNION ALL SELECT 'Anime Deutsch', 'Anime Bluray Tier 4', 122000
  UNION ALL SELECT 'Anime Deutsch', 'Anime Bluray Tier 5', 121000
  UNION ALL SELECT 'Anime Deutsch', 'Anime WEB-DL Tier 1', 85000
  UNION ALL SELECT 'Anime Deutsch', 'Anime WEB-DL Tier 2', 84000
  UNION ALL SELECT 'Anime Englisch', 'Anime Bluray Tier 1', 125000
  UNION ALL SELECT 'Anime Englisch', 'Anime Bluray Tier 2', 124000
  UNION ALL SELECT 'Anime Englisch', 'Anime Bluray Tier 3', 123000
  UNION ALL SELECT 'Anime Englisch', 'Anime Bluray Tier 4', 122000
  UNION ALL SELECT 'Anime Englisch', 'Anime Bluray Tier 5', 121000
  UNION ALL SELECT 'Anime Englisch', 'Anime WEB-DL Tier 1', 85000
  UNION ALL SELECT 'Anime Englisch', 'Anime WEB-DL Tier 2', 84000
  UNION ALL SELECT 'Anime Original', 'Anime Bluray Tier 1', 125000
  UNION ALL SELECT 'Anime Original', 'Anime Bluray Tier 2', 124000
  UNION ALL SELECT 'Anime Original', 'Anime Bluray Tier 3', 123000
  UNION ALL SELECT 'Anime Original', 'Anime Bluray Tier 4', 122000
  UNION ALL SELECT 'Anime Original', 'Anime Bluray Tier 5', 121000
  UNION ALL SELECT 'Anime Original', 'Anime WEB-DL Tier 1', 85000
  UNION ALL SELECT 'Anime Original', 'Anime WEB-DL Tier 2', 84000
) p
JOIN custom_formats cf ON cf.name = p.cf_name
WHERE NOT EXISTS (
  SELECT 1 FROM quality_profile_custom_formats qpcf
  WHERE qpcf.quality_profile_name = p.profile_name
    AND qpcf.custom_format_name = p.cf_name
    AND qpcf.arr_type = 'all'
);
