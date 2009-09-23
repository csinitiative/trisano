#!/usr/bin/env php

<?php
require_once('../lib/trisano-web-api-cmr.php');

$trisano = new TrisanoWebApiCmr;

$page = $trisano->get("/cmrs/new");
$trisano->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][last_name]', 'Jones');
$page = $trisano->browser->clickSubmitByName('commit');

exit(0);

?>
