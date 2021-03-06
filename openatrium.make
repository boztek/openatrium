core = "6.x"

; Contrib projects 

projects[admin][subdir] = "contrib"
projects[admin][version] = "2.0-alpha5"

projects[casetracker][subdir] = "contrib"
projects[casetracker][version] = "1.0-beta4"

projects[cck][subdir] = "contrib"
projects[cck][version] = "2.6"

projects[codefilter][subdir] = "contrib"
projects[codefilter][version] = "1.0"

projects[comment_upload][subdir] = "contrib"
projects[comment_upload][version] = "1.0-alpha5"

projects[content_profile][subdir] = "contrib"
projects[content_profile][version] = "1.0-beta4"

projects[context][subdir] = "contrib"
projects[context][version] = "3.0-alpha2"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.2"

projects[date][subdir] = "contrib"
projects[date][version] = "2.4"

projects[designkit][subdir] = "contrib"
projects[designkit][version] = "1.0-alpha4"

projects[diff][subdir] = "contrib"
projects[diff][version] = "2.1-alpha3"

projects[features][subdir] = "contrib"
projects[features][version] = "1.0-beta5"

projects[feedapi][subdir] = "contrib"
projects[feedapi][version] = "1.9-beta2"

projects[feedapi_mapper][subdir] = "contrib"
projects[feedapi_mapper][version] = "1.3"

projects[imageapi][subdir] = "contrib"
projects[imageapi][version] = "1.6"

projects[imagecache][subdir] = "contrib"
projects[imagecache][version] = "2.0-beta10"

projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1"

; @TODO add mailcomment (previously mail2web)

projects[mailhandler][subdir] = "contrib"
projects[mailhandler][version] = "1.8"

projects[markdown][subdir] = "contrib"
projects[markdown][version] = "1.1"

projects[messaging][subdir] = "contrib"
projects[messaging][version] = "2.2"

projects[notifications][subdir] = "contrib"
projects[notifications][version] = "2.2"

projects[notifications_team][subdir] = "contrib"
projects[notifications_team][version] = "2.0-beta5"

projects[og][subdir] = "contrib"
projects[og][version] = "2.0"
projects[og][patch][] = "http://drupal.org/files/issues/og_views_managelink_groupcontext.patch

projects[openidadmin][subdir] = "contrib"
projects[openidadmin][version] = "1.1"

projects[parser_ical][subdir] = "contrib"
projects[parser_ical][version] = "1.1"

projects[prepopulate][subdir] = "contrib"
projects[prepopulate][version] = "1.1"

projects[purl][subdir] = "contrib"
projects[purl][version] = "1.0-beta7"

projects[spaces][subdir] = "contrib"
projects[spaces][version] = "3.0-alpha2"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.0-beta3"

projects[token][subdir] = "contrib"
projects[token][version] = "1.12"

projects[transliteration][subdir] = "contrib"
projects[transliteration][version] = "2.1"

projects[ucreate][subdir] = "contrib"
projects[ucreate][version] = "1.0-beta2"

projects[views_bulk_operations][subdir] = "contrib"
projects[views_bulk_operations][version] = "1.8"

; Patched
; Explicit versions specified to ensure patches apply cleanly.
projects[views][subdir] = "contrib"
projects[views][type] = "module"
projects[views][download][type] = "cvs"
projects[views][download][module] = "contributions/modules/views"
projects[views][download][revision] = "DRUPAL-6--2"

; Temporarily disabling l10n patch. Needs to be updated to work with that
; latest 2.x or we need to move to 3.x. We can't continue to use 2.6 and
; expect to write and apply patches from 2.x HEAD to it.
; projects[views][patch][] = "http://drupal.org/files/issues/views-issue-357529.patch"

projects[views][patch][] = "http://drupal.org/files/issues/taxonomy_views_data_v2.patch"
projects[views][patch][] = "http://drupal.org/files/issues/views_check_perm_callback_0.patch"
projects[views][patch][] = "http://drupal.org/files/issues/views_namespaced_tabs_v2.patch"
projects[views][patch][] = "http://drupal.org/files/issues/compare_views_block_hash.patch"
projects[views][patch][] = "http://drupal.org/files/issues/views_default_reset.patch"

; Custom modules
projects[litecal][type] = "module"
projects[litecal][download][type] = "git"
projects[litecal][download][url] = "git://github.com/developmentseed/litecal.git"
projects[litecal][subdir] = "custom"

projects[litenode][type] = "module"
projects[litenode][download][type] = "git"
projects[litenode][download][url] = "git://github.com/developmentseed/litenode.git"
projects[litenode][subdir] = "custom"

; @TODO: determine the fate of messaging shoutbox.

projects[seed][location] = "http://code.developmentseed.org/fserver"
projects[seed][version] = "4.0"
projects[seed][subdir] = "custom"

projects[xref][type] = "module"
projects[xref][download][type] = "git"
projects[xref][download][url] = "git://github.com/developmentseed/xref.git"
projects[xref][subdir] = "custom"

; Development modules
projects[coder][subdir] = "developer"
projects[coder][version] = "2.0-beta1"

projects[devel][subdir] = "developer"
projects[devel][version] = "1.18"

projects[schema][subdir] = "developer"
projects[schema][version] = "1.6"

projects[simpletest][subdir] = "developer"
projects[simpletest][version] = "2.8"

; Features
projects[atrium_features][type] = "module"
projects[atrium_features][download][type] = "git"
projects[atrium_features][download][url] = "git://github.com/developmentseed/atrium_features.git"

; l10n
; No version for core_translation as there's only a 1.x-dev release node, no workies with Drush Make
projects[core_translation][subdir] = "l10n"

projects[l10n_client][subdir] = "l10n"
projects[l10n_client][version] = "1.7"

projects[l10n_update][type] = "module"
projects[l10n_update][download][type] = "git"
projects[l10n_update][download][url] = "git://github.com/developmentseed/l10n_update.git"
projects[l10n_update][subdir] = "l10n"
;projects[l10n_update][version] = ?

; Themes
projects[tao][location] = "http://code.developmentseed.org/fserver"
projects[tao][version] = "1.8"

projects[rubik][location] = "http://code.developmentseed.org/fserver"
projects[rubik][version] = "1.0-beta5"

projects[ginkgo][type] = "theme"
projects[ginkgo][download][type] = "git"
projects[ginkgo][download][url] = "git://github.com/developmentseed/ginkgo.git"

; @TODO: scene subtheme

; Libraries
libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"
