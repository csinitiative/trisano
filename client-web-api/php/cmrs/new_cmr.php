#!/usr/bin/env php

<?php
require_once('../lib/trisano-web-api-cmr.php');

$trisano = new TrisanoWebApiCmr;

$trisano->get("/cmrs/new");
$trisano->parse_args($argv);
$trisano->populate_form();
if ($trisano->browser->getTransportError()) {
  die($trisano->browser->getTransportError());
}
$page = $trisano->browser->clickSubmitByName('commit');

exit(0);

?>
