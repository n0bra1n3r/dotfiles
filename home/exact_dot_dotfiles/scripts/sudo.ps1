#!/usr/bin/env powershell

param(
  [String] $path
)

Start-Process 'bash' "-c `"PATH='$path' $args`"" -Verb runAs
