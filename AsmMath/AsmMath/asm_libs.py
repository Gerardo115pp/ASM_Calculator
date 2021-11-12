import ctypes
import pathlib, os
import numpy as np

dynamic_lib_path = pathlib.Path.joinpath(pathlib.Path(__file__).parent.resolve(), "libMathASM.so")
ctypes.cdll.LoadLibrary(dynamic_lib_path)
asm_math = ctypes.CDLL(dynamic_lib_path)


# Addition: support for float and int
ASMaddition = asm_math.addition
ASMadditionFloat = asm_math.additionF

# Subtraction: support for float and int
ASMsubtraction = asm_math.subtraction
ASMsubtractionFloat = asm_math.subtractionF

# Multiplication: support for float and int
ASMmultiplication = asm_math.multiplication
ASMmultiplicationFloat = asm_math.multiplicationF

# Division: support for float and int
ASMdivision = asm_math.division
ASMdivisionFloat = asm_math.divisionF

# Square root: support for float
ASMsquareRoot = asm_math.squareRoot

# Exponentiation: support for float as base and int as exponent
ASMexponentiation = asm_math.exponential


# Logarithm: support for float 
ASMlogarithm = asm_math.logarithm

#Anti-logarithm: support for float
ASMantilog = asm_math.antiLogarithm

# Sin: support for float
ASMsin = asm_math.sin

# Cos: support for float
ASMcos = asm_math.cos

# Tangent: support for float
ASMtangent = asm_math.tangent

# Arccos: support for float
ASMarccos = asm_math.arccos

# Arcsin: support for float
ASMarcsin = asm_math.arcsin

# Arctan: support for float
ASMarctan = asm_math.arctan

# Degrees to radians: support for float
ASMdegreesToRadians = asm_math.degsToRads

# Radians to degrees: support for float
ASMradiansToDegrees = asm_math.radToDegs

# changeSign: support for float
ASMchangeSign = asm_math.changeSign



