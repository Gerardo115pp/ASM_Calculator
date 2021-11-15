import ctypes
import AsmMath.asm_libs as ASM
from typing import Union, get_args, Any

Numeric = Union[int, float]
FuncPtr = type(ASM.ASMaddition)

IntegerPrecisionLimit = 2**64 - 1
FloatPrecisionLimit = 2**32 - 1

def prepareOperation(f: FuncPtr, *args) -> FuncPtr:
    assert len(args) >= 1
    argument_type = type(args[0])
    
    assert argument_type == int or argument_type == float, f"Expected all arguments to be of type int or float, got {argument_type}"
    
    assert all(type(arg) is argument_type for arg in args), f"Expected all arguments to be of type {argument_type}, got {args}"
    
    c_type = ctypes.c_int64 if argument_type is int else ctypes.c_double

    f.argtypes = [c_type] * len(args)
    f.restype = c_type
    
    return f

def isNumeric(a:Any) -> bool:
    return isinstance(a, get_args(Numeric))

#====================== OPERATIONS ======================

def addition(a: Numeric, b:Numeric) -> Numeric:
    func = ASM.ASMaddition if type(a) is int else ASM.ASMadditionFloat
    func = prepareOperation(func, a, b)
    return func(a, b)
    
def subtraction(a: Numeric, b: Numeric) -> Numeric:
    func = ASM.ASMsubtraction if type(a) is int else ASM.ASMsubtractionFloat
    func = prepareOperation(func, a, b)
    return func(a, b)
    
def multiplication(a: Numeric, b: Numeric) -> Numeric:
    func = ASM.ASMmultiplication if type(a) is int else ASM.ASMmultiplicationFloat
    func = prepareOperation(func, a, b)
    return func(a, b)
    
def division(a: Numeric, b: Numeric) -> Numeric:
    func = ASM.ASMdivision if type(a) is int else ASM.ASMdivisionFloat
    func = prepareOperation(func, a, b)
    return func(a, b)

def factorial(a: int) -> int:
    if type(a) is float:
        print("WARNING:Factorial of a float is not defined, converting to float")
        a = int(a)
    if a > 20:
        print("WARNING:Factorial of a number greater than 20 will  lose precision")
    
    ASM.ASMfactorial.argtypes = [ctypes.c_int64]
    ASM.ASMfactorial.restype = ctypes.c_int64
    
    return ASM.ASMfactorial(int(a))

def squareRoot(a: Numeric) -> Numeric:
    if not isinstance(a, float):
        a = float(a)
    func = prepareOperation(ASM.ASMsquareRoot, a)
    return func(a)

def exponential(a: float) -> float:
    ASM.ASMexponentiation.argtypes = [ctypes.c_double]
    ASM.ASMexponentiation.restype = ctypes.c_double
    return ASM.ASMexponentiation(float(a))

def power(a: Numeric, b: Numeric) -> float:
    if b >= 0 and type(b) is int:        
        ASM.ASMPowerNexp.argtypes = [ctypes.c_double, ctypes.c_int64]
        ASM.ASMPowerNexp.restype = ctypes.c_double
        return ASM.ASMPowerNexp(float(a), int(b))
    else:
        ASM.ASMPowerRexp.argtypes = [ctypes.c_double, ctypes.c_double]
        ASM.ASMPowerRexp.restype = ctypes.c_double
        
        return ASM.ASMPowerRexp(float(a), float(b))

def logarithm(a:float, base:float) -> float:
    ASM.ASMlogarithm.argtypes = [ctypes.c_double, ctypes.c_double]
    ASM.ASMlogarithm.restype = ctypes.c_double
    
    return ASM.ASMlogarithm(float(a), float(base))

def antilog(a: float) -> float:
    ASM.ASMantilog.argtypes = [ctypes.c_double]
    ASM.ASMantilog.restype = ctypes.c_double
    
    return ASM.ASMantilog(float(a))

def sin(a: float) -> float:
    ASM.ASMsin.argtypes = [ctypes.c_double]
    ASM.ASMsin.restype = ctypes.c_double
    
    return ASM.ASMsin(float(a))

def cos(a: float) -> float:
    ASM.ASMcos.argtypes = [ctypes.c_double]
    ASM.ASMcos.restype = ctypes.c_double
    
    return ASM.ASMcos(float(a))

def tan(a: float) -> float:
    ASM.ASMtangent.argtypes = [ctypes.c_double]
    ASM.ASMtangent.restype = ctypes.c_double
    
    return ASM.ASMtangent(float(a))

def arccos(a: float) -> float:
    ASM.ASMarccos.argtypes = [ctypes.c_double]
    ASM.ASMarccos.restype = ctypes.c_double
    
    return ASM.ASMarccos(float(a))

def arcsin(a: float) -> float:
    ASM.ASMarcsin.argtypes = [ctypes.c_double]
    ASM.ASMarcsin.restype = ctypes.c_double
    
    return ASM.ASMarcsin(float(a))

def arctan(a: float) -> float:
    ASM.ASMarctan.argtypes = [ctypes.c_double]
    ASM.ASMarctan.restype = ctypes.c_double
    
    return ASM.ASMarctan(float(a))

# convertions:

def degreesToRadians(a: float) -> float:
    ASM.ASMdegreesToRadians.argtypes = [ctypes.c_double]
    ASM.ASMdegreesToRadians.restype = ctypes.c_double
    
    return ASM.ASMdegreesToRadians(float(a))    

def radiansToDegrees(a: float) -> float:
    ASM.ASMradiansToDegrees.argtypes = [ctypes.c_double]
    ASM.ASMradiansToDegrees.restype = ctypes.c_double
    
    return ASM.ASMradiansToDegrees(float(a))

def changeSign(a: float) -> float:
    ASM.ASMchangeSign.argtypes = [ctypes.c_double]
    ASM.ASMchangeSign.restype = ctypes.c_double
    
    return ASM.ASMchangeSign(float(a))

#====================== END OPERATIONS ======================

