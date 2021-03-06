<?php
// $Id$

/**
 * Implementation of hook_profile_details().
 */
function openatrium_profile_details() {
  return array(
    'name' => 'Open Atrium',
    'description' => 'Open Atrium by Development Seed.',
    'old_short_name' => 'atrium_installer',
  );
}

/**
 * Implementation of hook_profile_modules().
 */
function openatrium_profile_modules() {
  $modules = array(
     // Drupal core
    'block',
    'comment',
    'dblog',
    'filter',
    'help',
    'menu',
    'node',
    'openid',
    'search',
    'system', 
    'taxonomy',
    'upload',
    'user',
    // Admin
    'admin',
    // Views
    'views', 'litenode',
    // OG
    'og', 'og_access', 'og_actions', 'og_views',
    // Context
    'context', 'context_ui', 'context_layouts',
    // CTools
    'ctools',
    // Date
    'date_api', 'date_timezone',
    // Features
    'features',
    // Image
    'imageapi', 'imageapi_gd', 'imagecache',
    // Token
    'token',
    // Transliteration
    'transliteration',
    // Messaging
    'messaging', 'messaging_mail',
    // Notifications
    'notifications', 'notifications_content', 'notifications_views',
    // Open ID
    'openidadmin',
    // PURL
    'purl',
    // Seed
    'seed',
    // Spaces
    'spaces', 'spaces_user', 'spaces_og',
    // Ucreate
    'ucreate', 'ucreate_og',
  );

  // If language is not English we add the 'atrium_translate' module the first
  // To get some modules installed properly we need to have translations loaded
  // We also use it to check connectivity with the translation server on hook_requirements()
  if (_openatrium_language_selected()) {
    // We need locale before l10n_update because it adds fields to locale tables
    $modules[] = 'locale';
    $modules[] = 'l10n_update';
    $modules[] = 'atrium_translate';
  }

  return $modules;
}

/**
 * Returns an array list of atrium features (and supporting) modules.
 */
function _openatrium_atrium_modules() {
  return array(
    // Strongarm
    'strongarm',
    // Core features
    'book',
    // Casetracker
    'casetracker',
    // Calendar, date
    'date', 'date_popup', 'litecal',
    // CCK
    'content', 'nodereference', 'text', 'optionwidgets',
    // FeedAPI
    'feedapi', 'feedapi_node', 'feedapi_mapper', 'feedapi_inherit', 'parser_ical',
    // Determine fate of shoutbox.
    'messaging_shoutbox',
    // Notifications
    // 'mail2web', 'mailhandler',
    'notifications_team',
    // Content profile
    'content_profile',
    // Atrium features
    'atrium', 'atrium_blog', 'atrium_book', 'atrium_calendar', 'atrium_casetracker', 'atrium_groups', 'atrium_members', 'atrium_profile', 'atrium_shoutbox',
    // Dashboard
    'spaces_dashboard', 'jquery_ui',
    // Formats
    'codefilter', 'markdown',
    // Others
    'comment_upload', 'diff', 'prepopulate', 'xref',
    // DesignKit
    'color', 'designkit',
    // VBO
    'views_bulk_operations',
  );
}

/**
 * Implementation of hook_profile_task_list().
 */
function openatrium_profile_task_list() {
  if (_openatrium_language_selected()) {
    $tasks['intranet-translation-batch'] = st('Download and import translation');
  }
  $tasks['intranet-modules-batch'] = st('Install intranet modules');
  $tasks['intranet-configure-batch'] = st('Configure intranet');
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function openatrium_profile_tasks(&$task, $url) {
  global $profile, $install_locale;
  
  // Just in case some of the future tasks adds some output
  $output = '';

  // Download and install translation if needed
  if ($task == 'profile') {
    if (_openatrium_language_selected() && module_exists('atrium_translate')) {
      module_load_install('atrium_translate');
      if ($batch = atrium_translate_create_batch($install_locale, 'install')) {
        $batch['finished'] = '_openatrium_translate_batch_finished';
        // Remove temporary variables and set install task
        variable_del('install_locale_batch_components');
        variable_set('install_task', 'intranet-translation-batch');
        batch_set($batch);
        batch_process($url, $url);
        // Jut for cli installs. We'll never reach here on interactive installs.
        return;
      }
    }
    // If we reach here, means no language install, move on to the next task
    $task = 'intranet-modules';
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('intranet-modules-batch', 'intranet-translation-batch', 'intranet-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }
  
  // Install some more modules and maybe localization helpers too
  if ($task == 'intranet-modules') {
    $modules = _openatrium_atrium_modules();
    $files = module_rebuild_cache();
    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }    
    $batch['finished'] = '_openatrium_profile_batch_finished';
    $batch['title'] = st('Installing @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['error_message'] = st('The installation has encountered an error.');

    // Start a batch, switch to 'intranet-modules-batch' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'intranet-modules-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }

  // Run additional configuration tasks
  // @todo Review all the cache/rebuild options at the end, some of them may not be needed
  // @todo Review for localization, the time zone cannot be set that way either
  if ($task == 'intranet-configure') {
    $batch['title'] = st('Configuring @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_openatrium_intranet_configure', array());
    $batch['operations'][] = array('_openatrium_intranet_configure_check', array());
    $batch['finished'] = '_openatrium_intranet_configure_finished';
    variable_set('install_task', 'intranet-configure-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }  

  return $output;
}

/**
 * Check whether we are installing in a language other than English
 */
function _openatrium_language_selected() {
  global $install_locale;
  return !empty($install_locale) && ($install_locale != 'en');
}

/**
 * Configuration. First stage.
 */
function _openatrium_intranet_configure() {
  global $install_locale;

  // Disable the english locale if using a different default locale.
  if (!empty($install_locale) && ($install_locale != 'en')) {
    db_query("DELETE FROM {languages} WHERE language = 'en'");
  }

  // Remove default input filter formats
  $result = db_query("SELECT * FROM {filter_formats} WHERE name IN ('%s', '%s')", 'Filtered HTML', 'Full HTML');
  while ($row = db_fetch_object($result)) {
    db_query("DELETE FROM {filter_formats} WHERE format = %d", $row->format);
    db_query("DELETE FROM {filters} WHERE format = %d", $row->format);
  }

  // Eliminate the access content perm from anonymous users.
  db_query("UPDATE {permission} set perm = '' WHERE rid = 1");

  // Create user picture directory
  $picture_path = file_create_path(variable_get('user_picture_path', 'pictures'));
  file_check_directory($picture_path, 1, 'user_picture_path');

  // Create freetagging vocab
  $vocab = array(
    'name' => 'Keywords',
    'multiple' => 0,
    'required' => 0,
    'hierarchy' => 0,
    'relations' => 0,
    'module' => 'event',
    'weight' => 0,
    'nodes' => array('blog' => 1, 'book' => 1, 'casetracker_basic_case' => 1, 'casetracker_basic_project' => 1, 'event' => 1),
    'tags' => TRUE,
    'help' => t('Enter tags related to your post.'),
  );
  taxonomy_save_vocabulary($vocab);

  // Set time zone
  // @TODO: This is not sufficient. We either need to display a message or
  // derive a default date API location.
  $tz_offset = date('Z');
  variable_set('date_default_timezone', $tz_offset);

  // Set a default footer message.
  variable_set('site_footer', '&copy; 2009 '. l('Development Seed', 'http://www.developmentseed.org', array('absolute' => TRUE)));

  // Revert key components that are overridden by others on install.
  $revert = array(
    'atrium' => array('user', 'variable', 'filter'),
    'atrium_blog' => array('user', 'variable'),
    'atrium_book' => array('user', 'variable'),
    'atrium_calendar' => array('user', 'variable'),
    'atrium_casetracker' => array('user', 'variable'),
    'atrium_groups' => array('user', 'variable'),
    'atrium_members' => array('user', 'variable'),
    'atrium_profile' => array('user', 'variable'),
    'atrium_shoutbox' => array('user', 'variable'),
  );
  features_revert($revert);
}

/**
 * Configuration. Second stage.
 */
function _openatrium_intranet_configure_check() {
  // This isn't actually necessary as there are no node_access() entries,
  // but we run it to prevent the "rebuild node access" message from being
  // shown on install.
  node_access_rebuild();

  // @TODO: Don't appear to be necessary for functional Atrium install.
  // Determine if these were added for Aegir.

  // Rebuild key tables/caches
  // module_rebuild_cache();
  // drupal_get_schema(NULL, TRUE);
  // drupal_flush_all_caches();    

  // Set default theme. This must happen after drupal_flush_all_caches(), which
  // will run system_theme_data() without detecting themes in the install
  // profile directory.
  _openatrium_system_theme_data();
  db_query("UPDATE {blocks} SET status = 0, region = ''"); // disable all DB blocks
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'ginkgo');
  variable_set('theme_default', 'ginkgo');
}

/**
 * Finish configuration batch
 * 
 * @todo Handle error condition
 */
function _openatrium_intranet_configure_finished($success, $results) {
  variable_set('atrium_install', 1);
  // Get out of this batch and let the installer continue. If loaded translation,
  // we skip the locale remaining batch and move on to the next.
  // However, if we didn't make it with the translation file, or they downloaded
  // an unsupported language, we let the standard locale do its work.
  if (variable_get('atrium_translate_done', 0)) {
    variable_set('install_task', 'finished');
  }
  else {
    variable_set('install_task', 'profile-finished');
  } 
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _openatrium_profile_batch_finished($success, $results) {
  variable_set('install_task', 'intranet-configure');
}

/**
 * Finished callback for the first locale import batch.
 *
 * Advance installer task to the configure screen.
 */
function _openatrium_translate_batch_finished($success, $results) {
  include_once 'includes/locale.inc';
  // Let the installer now we've already imported locales
  variable_set('atrium_translate_done', 1);
  variable_set('install_task', 'intranet-modules');
  _locale_batch_language_finished($success, $results);
}

/**
 * Alter some forms implementing hooks in system module namespace
 * This is a trick for hooks to get called, otherwise we cannot alter forms
 */

/**
 * @TODO: This might be impolite/too aggressive. We should at least check that
 * other install profiles are not present to ensure we don't collide with a
 * similar form alter in their profile.
 *
 * Set Open Atrium as default install profile.
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'openatrium';
  }
}

/**
 * Set English as default language.
 * 
 * If no language selected, the installation crashes. I guess English should be the default 
 * but it isn't in the default install. @todo research, core bug?
 */
function system_form_install_select_locale_form_alter(&$form, $form_state) {
  $form['locale']['en']['#value'] = 'en';
}

/**
 * Alter the install profile configuration form and provide timezone location options.
 */
function system_form_install_configure_form_alter(&$form, $form_state) {
  $form['site_information']['site_name']['#default_value'] = 'Open Atrium';
  $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];

  if (function_exists('date_timezone_names') && function_exists('date_timezone_update_site')) {
    $form['server_settings']['date_default_timezone']['#access'] = FALSE;
    $form['server_settings']['#element_validate'] = array('date_timezone_update_site');
    $form['server_settings']['date_default_timezone_name'] = array(
      '#type' => 'select',
      '#title' => t('Default time zone'),
      '#default_value' => NULL,
      '#options' => date_timezone_names(FALSE, TRUE),
      '#description' => t('Select the default site time zone. If in doubt, choose the timezone that is closest to your location which has the same rules for daylight saving time.'),
      '#required' => TRUE,
    );
  }
}

/**
 * Reimplementation of system_theme_data(). The core function's static cache
 * is populated during install prior to active install profile awareness.
 * This workaround makes enabling themes in profiles/[profile]/themes possible.
 */
function _openatrium_system_theme_data() {
  global $profile;
  $profile = 'openatrium';

  $themes = drupal_system_listing('\.info$', 'themes');
  $engines = drupal_system_listing('\.engine$', 'themes/engines');

  $defaults = system_theme_default();

  $sub_themes = array();
  foreach ($themes as $key => $theme) {
    $themes[$key]->info = drupal_parse_info_file($theme->filename) + $defaults;

    if (!empty($themes[$key]->info['base theme'])) {
      $sub_themes[] = $key;
    }

    $engine = $themes[$key]->info['engine'];
    if (isset($engines[$engine])) {
      $themes[$key]->owner = $engines[$engine]->filename;
      $themes[$key]->prefix = $engines[$engine]->name;
      $themes[$key]->template = TRUE;
    }

    // Give the stylesheets proper path information.
    $pathed_stylesheets = array();
    foreach ($themes[$key]->info['stylesheets'] as $media => $stylesheets) {
      foreach ($stylesheets as $stylesheet) {
        $pathed_stylesheets[$media][$stylesheet] = dirname($themes[$key]->filename) .'/'. $stylesheet;
      }
    }
    $themes[$key]->info['stylesheets'] = $pathed_stylesheets;

    // Give the scripts proper path information.
    $scripts = array();
    foreach ($themes[$key]->info['scripts'] as $script) {
      $scripts[$script] = dirname($themes[$key]->filename) .'/'. $script;
    }
    $themes[$key]->info['scripts'] = $scripts;

    // Give the screenshot proper path information.
    if (!empty($themes[$key]->info['screenshot'])) {
      $themes[$key]->info['screenshot'] = dirname($themes[$key]->filename) .'/'. $themes[$key]->info['screenshot'];
    }
  }

  foreach ($sub_themes as $key) {
    $themes[$key]->base_themes = system_find_base_themes($themes, $key);
    // Don't proceed if there was a problem with the root base theme.
    if (!current($themes[$key]->base_themes)) {
      continue;
    }
    $base_key = key($themes[$key]->base_themes);
    foreach (array_keys($themes[$key]->base_themes) as $base_theme) {
      $themes[$base_theme]->sub_themes[$key] = $themes[$key]->info['name'];
    }
    // Copy the 'owner' and 'engine' over if the top level theme uses a
    // theme engine.
    if (isset($themes[$base_key]->owner)) {
      if (isset($themes[$base_key]->info['engine'])) {
        $themes[$key]->info['engine'] = $themes[$base_key]->info['engine'];
        $themes[$key]->owner = $themes[$base_key]->owner;
        $themes[$key]->prefix = $themes[$base_key]->prefix;
      }
      else {
        $themes[$key]->prefix = $key;
      }
    }
  }

  // Extract current files from database.
  system_get_files_database($themes, 'theme');
  db_query("DELETE FROM {system} WHERE type = 'theme'");
  foreach ($themes as $theme) {
    $theme->owner = !isset($theme->owner) ? '' : $theme->owner;
    db_query("INSERT INTO {system} (name, owner, info, type, filename, status, throttle, bootstrap) VALUES ('%s', '%s', '%s', '%s', '%s', %d, %d, %d)", $theme->name, $theme->owner, serialize($theme->info), 'theme', $theme->filename, isset($theme->status) ? $theme->status : 0, 0, 0);
  }
}
