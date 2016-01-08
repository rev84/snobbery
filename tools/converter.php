<?php

$lyrics = str_replace(["\r\n","\r"], "\n", file_get_contents('./timetable.txt'));

$records = explode("\n", $lyrics);
for ($i = 0; $i < count($records); $i++) {
  $records[$i] = preg_split('`\t`', $records[$i]);
}

$json = json_encode($records);

file_put_contents('../json/lyrics.js', 'var LYRICS = '.$json);
