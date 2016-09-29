<?php
/**
 * Parse the content of "msc"(magic script compiler) and return a json format string
 * @param string $path - file path of "msc"
 * @return string - a json format string with version info and structures of "msc"
 */

$MS_MAGIC_SPLIT_LINE = '/^#M={77}S$/';
$VERSION_PATTERN = '/^# Magic Script Compiler ([0-9]\.[0-9])$/';
$LIBRARY_PATTERN = '/^# Compiled by MAGIC-SCRIPT from source: \.ms\.d\/(.*)\.sh$/';
$FUNCTION_PATTERN = '/(ms_.*)\(\) {$/';

function msc_parser($path) {
    $result = array('VERSION' => NULL, 'LIBRARIES' => array());

    $handle = fopen($path, "r");
    if ($handle) {
        $curr_lib = NULL;
        $line_no = 0;

        $parsing_state = 'not_in_magic_blocks';
        while (($line = fgets($handle)) !== false) {
            $line_no++;
            switch ($parsing_state) {
                case 'not_in_magic_blocks':
                    if (preg_match($GLOBALS['VERSION_PATTERN'], $line, $matches))
                        $result['VERSION'] = $matches[1];
                    elseif (preg_match($GLOBALS['LIBRARY_PATTERN'], $line, $matches)) {
                        $curr_lib = $matches[1];
                        $parsing_state = 'entering_a_magic_block';
                    } else;

                    break;
                case 'entering_a_magic_block':
                    $result['LIBRARIES'][$curr_lib] = array();
                    $result['LIBRARIES'][$curr_lib]['LINENO'] = $line_no;
                    $result['LIBRARIES'][$curr_lib]['FUNCTIONS'] = array();

                    if (preg_match($GLOBALS['MS_MAGIC_SPLIT_LINE'], $line, $matches))
                        $parsing_state = 'inside_a_magic_block';
                    else {
                        echo "ERROR: parse error around line:" . $line;
                        exit(1);
                    }

                    break;
                case 'inside_a_magic_block':
                    if (preg_match($GLOBALS['FUNCTION_PATTERN'], $line, $matches)) {
                        $result['LIBRARIES'][$curr_lib]['FUNCTIONS'][$matches[1]] = array();
                        $result['LIBRARIES'][$curr_lib]['FUNCTIONS'][$matches[1]]['LINENO']
                            = $line_no;
                    } elseif (preg_match($GLOBALS['MS_MAGIC_SPLIT_LINE'], $line, $matches)) {
                        $parsing_state = 'not_in_magic_blocks';
                    } else;

                    break;
                case 'leaving_a_magic_block':
                    break;
                default:
                    echo "ERROR: file to be parsed is not in standard format.";
            }
        }

        fclose($handle);
    } else {
        echo "ERROR: cannot read this file.";
    }
    return json_encode($result, JSON_PRETTY_PRINT);
}

echo msc_parser($_GET["f"]);
