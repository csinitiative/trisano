<?php

require_once('../lib/simpletest/browser.php');

class TrisanoWebApiCmr {
  public $browser;
  private $base_url;

  function __construct() {
    $this->browser = &new SimpleBrowser();
    if (!isset($_ENV['TRISANO_BASE_URL'])) die('Missing TRISANO_BASE_URL');
    $this->base_url = $_ENV['TRISANO_BASE_URL'];
  }

  public function get($path) {
    return $this->browser->get($this->base_url . $path);
  }
}
?>
