from AsmMath.operations import *
from typing import Callable
import math

TOO = Callable[[int, int], int] # TOO stands for Two Operators Operations

def testTwoOperatosOperations(operasion: TOO, a: Numeric, b: Numeric, expected_value: Numeric) -> bool:
    """
    Test the two operatos operations
    """
    test_result = abs((result := operasion(a, b)) - expected_value) <= 10**-4
    print(f"The result of {a} {operasion.__name__} {b} is: {result}, {operasion.__name__} {'OK' if test_result else 'FAIL'}")
    if not test_result:
        print(f"Expected result: {expected_value}, percentual error: {abs(result - expected_value)/expected_value*100:.5f}%")
    return test_result

def testOneOperatorOperation(operasion: TOO, a: Numeric, expected_value: Numeric) -> bool:
    """
    Test the one operatos operations
    """
    test_result = abs((result := operasion(a)) - expected_value) <= 10**-4
    print(f"The result of {a} {operasion.__name__} is: {result}, {operasion.__name__} {'OK' if test_result else 'FAIL'}")
    if not test_result:
        print(f"Expected result: {expected_value}, percentual error: {abs(result - expected_value)/expected_value*100:.5f}%")
    return test_result 

def testAddition() -> bool:
    """
    Test the addition function
    """
    testTwoOperatosOperations(addition, 15, 5, 20)
    testTwoOperatosOperations(addition, 5.0, 2.5, 7.5)
    
def testSubtraction() -> bool:
    """
    Test the subtraction function
    """
    testTwoOperatosOperations(subtraction, 15, 5, 10)
    testTwoOperatosOperations(subtraction, 5.0, 2.5, 2.5)

def testMultiplication() -> bool:
    """
    Test the multiplication function
    """
    testTwoOperatosOperations(multiplication, 15, 5, 75)
    testTwoOperatosOperations(multiplication, 5.0, 2.5, 12.5)

def testDivision() -> bool:
    """
    Test the division function
    """
    testTwoOperatosOperations(division, 15, 5, 3)
    testTwoOperatosOperations(division, 5.0, 2.5, 2.0)

def testFactorial():
    testOneOperatorOperation(factorial, 5, 120)
    testOneOperatorOperation(factorial, 0, 1)
    testOneOperatorOperation(factorial, 20, math.factorial(20))
    testOneOperatorOperation(factorial, 2, 2)

def testSquareRoot() -> bool:
    """
    Test the square root function
    """
    testOneOperatorOperation(squareRoot, 25, 5)
    testOneOperatorOperation(squareRoot, 69, math.sqrt(69))

def testPower():
    testTwoOperatosOperations(power, 6.6, 3, 6.6**3)
    testTwoOperatosOperations(power, 6.6, 0, 1)
    testTwoOperatosOperations(power, 5, 3.3, 5**3.3)
    testTwoOperatosOperations(power, 30, 5, 30**5)

def testExponential() -> bool:
    """
    Test the exponential function
    """
    testOneOperatorOperation(exponential, 3.4, math.exp(3.4))

def testLogarithm():
    testTwoOperatosOperations(logarithm, 8, 5, math.log(8, 5))
    testTwoOperatosOperations(logarithm, 8, 2, math.log(8, 2))
    testTwoOperatosOperations(logarithm, 8, math.e, math.log(8, math.e))

def testAntilog():
    testOneOperatorOperation(antilog, 5.6, 10**5.6)

def testSin():
    testOneOperatorOperation(sin, math.pi/4, math.sin(math.pi/4))
    testOneOperatorOperation(sin, math.pi/6, math.sin(math.pi/6))
    testOneOperatorOperation(sin, 9, math.sin(9))
    
def testCos():
    testOneOperatorOperation(cos, math.pi/4, math.cos(math.pi/4))
    testOneOperatorOperation(cos, math.pi/6, math.cos(math.pi/6))
    testOneOperatorOperation(cos, 9, math.cos(9))

def testTangent():
    testOneOperatorOperation(tan, math.pi/4, math.tan(math.pi/4))
    testOneOperatorOperation(tan, math.pi/6, math.tan(math.pi/6))
    testOneOperatorOperation(tan, 9, math.tan(9))

def testArccos():
    testOneOperatorOperation(arccos, 1, 0)
    testOneOperatorOperation(arccos, 0.9, math.acos(0.9))
    
def testArcsin():
    testOneOperatorOperation(arcsin, 1, math.pi/2)
    testOneOperatorOperation(arcsin, 0.9, math.asin(0.9))

def testArcTan():
    testOneOperatorOperation(arctan, 1, math.pi/4)
    testOneOperatorOperation(arctan, 0.9, math.atan(0.9))

def testDegreesToRadians():
    testOneOperatorOperation(degreesToRadians, 90, math.pi/2)

def testRadiansToDegrees():
    testOneOperatorOperation(radiansToDegrees, math.pi/2, 90)

def testChangeSign():
    testOneOperatorOperation(changeSign, -5, 5)
    testOneOperatorOperation(changeSign, 5, -5)

def test():
    print("\nTesting the addition function:")
    testAddition()
    
    print("\nTesting the subtraction function:")
    testSubtraction()
    
    print("\nTesting the multiplication function:")
    testMultiplication()
    
    print("\nTesting the division function:")
    testDivision()
    
    print("\nTesting the factorial function:")
    testFactorial()
    
    print("\nTesting the square root function:")
    testSquareRoot()
    
    print("\nTesting the power function:")
    testPower()
    
    print("\nTesting the exponential function:")
    testExponential()
    
    print("\nTesting the logarithm function:")
    testLogarithm()
    
    print("\nTesting the antilog function:")
    testAntilog()
    
    print("\nTesting the sin function:")
    testSin()
    
    print("\nTesting the cos function:")
    testCos()
    
    print("\nTesting the tangent function:")
    testTangent()
    
    print("\nTesting the arccos function:")
    testArccos()
    
    print("\nTesting the arcsin function:")
    testArcsin()
    
    print("\nTesting the arctan function:")
    testArcTan()
    
    print("\nTesting the degreesToRadians function:")
    testDegreesToRadians()
    
    print("\nTesting the radiansToDegrees function:")
    testRadiansToDegrees()
    
    print("\nTesting the changeSign function:")
    testChangeSign()
    
    
    
if __name__ == "__main__":
    test()