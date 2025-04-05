import time
from common import test_program, bcolors

def testcase_aaa_asm():
    program_file = "./asm_examples/aaa.asm"
    expected_registers = ["00000000", "0000000A", "00000014", "00000005", "0000000F", "0000001E", "00000019", "0000000F",
                          "FFFFFFEA", "0000000E", "0000000F", "0000000C", "00000019", "0000000C", "00000064", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_bbb_asm():
    program_file = "./asm_examples/bbb.asm"
    expected_registers = ["00000000", "0000000A", "00000014", "00000005", "0000000F", "00000064", "0000000A", "00000014",
                          "00000005", "0000001E", "00000019", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_ccc_asm():
    program_file = "./asm_examples/ccc.asm"
    expected_registers = ["00000000", "0000000A", "00000004", "0000000F", "FFFFFFEC", "00000008", "00000028", "00000007",
                          "FFFFFFF6", "000000A0", "00000000", "FFFFFFFE", "0000002F", "0000002F", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_ddd_asm():
    program_file = "./asm_examples/ddd.asm"
    expected_registers = ["00000000", "0000000A", "00000004", "00000014", "FFFFFFF1", "00000064", "00000028", "0000000A",
                          "FFFFFFF8", "0000000A", "00000004", "00000014", "00000000", "00000014", "0000001E", "ABCD0000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_eee_asm():
    program_file = "./asm_examples/eee.asm"
    expected_registers = ["00000000", "0000000A", "0000000A", "0000000B", "0000000B", "00000005", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_fff_asm():
    program_file = "./asm_examples/fff.asm"
    expected_registers = ["00000000", "00000005", "00000019", "00000005", "0000000B", "00000000", "00000000", "00000045",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "0000002C"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_ggg_asm():
    program_file = "./asm_examples/ggg.asm"
    expected_registers = ["00000000", "0000000A", "0000000A", "00000001", "0000000A", "00000000", "00000001", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
                          "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000", "00000000"]
    test_result = test_program(program_file, expected_registers)
    return test_result

def testcase_all():
    regresion_result = True

    test_functions = [testcase_aaa_asm,
                      testcase_bbb_asm,
                      testcase_ccc_asm,
                      testcase_ddd_asm,
                      testcase_eee_asm,
                      testcase_fff_asm,
                      testcase_ggg_asm]

    for testcase in test_functions:
        print(f"Running test < {testcase.__name__} >")
        regresion_result = regresion_result and testcase()
        time.sleep(0.5)

    print(f"Regress successful ? {bcolors.OKGREEN if regresion_result==True else bcolors.FAIL} {regresion_result} {bcolors.ENDC}")
    return regresion_result
