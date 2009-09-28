<?php

require_once('../lib/simpletest/browser.php');

class TrisanoWebApi {
  public $browser;
  private $base_url;
  public $page;

  function __construct() {
    if (!isset($_ENV['TRISANO_BASE_URL'])) die('Missing TRISANO_BASE_URL environment variable');
    $this->browser = &new SimpleBrowser();
    $this->base_url = $_ENV['TRISANO_BASE_URL'];

    if (isset($_ENV['TRISANO_API_AUTH']) && strtolower($_ENV['TRISANO_API_AUTH']) != 'none') {
      $username = $_ENV['TRISANO_API_USER'] || die('Missing TRISANO_API_USER environment variable');
      $password = $_ENV['TRISANO_API_PASS'] || die('Missing TRISANO_API_PASS environment variable');
    }

    if ($_ENV['TRISANO_API_AUTH'] == 'basic') {
     $browser->authenticate($username, $password);
    }
    elseif ($_ENV['TRISANO_API_AUTH'] == 'siteminder') {
      $auth_url = $_ENV['TRISANO_SM_URL'] || die('Missing TRISANO_SM_URL environment variable');

      // Generate Siteminder cookies
      $browser->post($auth_url, array('LoginID' => $username,
                                      'Password' => $password,
                                      'Dispatch' => 'loginAuth'));
    }
  }

  public function get($path) {
    $this->page = $this->browser->get($this->base_url . $path);
    return $this->page;
  }

  public function get_page() {
    return $this->page;
  }

}
