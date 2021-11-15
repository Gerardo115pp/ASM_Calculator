import Operation, {operation_types} from "./operation";

// Addition:
const addition = new Operation(operation_types.TWO_OPERAND, "+", "+");

// Subtraction:
const substraction = new Operation(operation_types.TWO_OPERAND, "-", "-");
substraction.shortcut = "s"

// Multiplication:
const multiplication = new Operation(operation_types.TWO_OPERAND, "*", "*");

// Division:
const division = new Operation(operation_types.TWO_OPERAND, "/", "/");
division.shortcut = "d";


// Square root:
const square_root = new Operation(operation_types.ONE_OPERAND, "sqrt", "√x");
square_root.operation_format = "√{a}";
// Power:
const power = new Operation(operation_types.TWO_OPERAND, "^", "xᵃ");
power.operation_format = "{a}^{b}";


// Exponential:
const exponential = new Operation(operation_types.ONE_OPERAND, "exp", "exp(x)");
exponential.operation_format = "exp({a})";

// Logarithm:
const logarithm = new Operation(operation_types.TWO_OPERAND, "log", "logᵃ");
logarithm.operation_format = "log_{b}({a})";
logarithm.shortcut = "l";

// Anti-logarithm:
const anti_logarithm = new Operation(operation_types.ONE_OPERAND, "antilog", "log⁻¹");
anti_logarithm.operation_format = "antilog({a})";
anti_logarithm.shortcut = "a";


// Sine:
const sine = new Operation(operation_types.ONE_OPERAND, "sin", "sin");
sine.operation_format = "sin({a})";
sine.shortcut = "s";

// Cosine:
const cosine = new Operation(operation_types.ONE_OPERAND, "cos", "cos");
cosine.operation_format = "cos({a})";
cosine.shortcut = "c";

// Tangent:
const tangent = new Operation(operation_types.ONE_OPERAND, "tan", "tan");
tangent.operation_format = "tan({a})";

// Arc sine:
const arcsine = new Operation(operation_types.ONE_OPERAND, "arcsin", "sin⁻¹");
arcsine.operation_format = "arcsin({a})";

// Arc cosine:
const arccosine = new Operation(operation_types.ONE_OPERAND, "arccos", "cos⁻¹");
arccosine.operation_format = "arccos({a})";


// Arc tangent:
const arctangent = new Operation(operation_types.ONE_OPERAND, "arctan", "tan⁻¹");
arctangent.operation_format = "arctan({a})";


// Degrees to radians:
const rads = new Operation(operation_types.ONE_OPERAND, "rads", "rad");
rads.operation_format = "rads({a})";
rads.shortcut = "r";

// Radians to degrees:
const degs = new Operation(operation_types.ONE_OPERAND, "degs", "deg");
degs.operation_format = "degs({a})";

// -x:
const negative = new Operation(operation_types.ONE_OPERAND, "-x", "-x");
negative.operation_format = "-({a})";

// x!
const factorial = new Operation(operation_types.ONE_OPERAND, "!", "x!");
factorial.operation_format = "{a}!";
factorial.shortcut = "!";

let operations = [
    addition,
    substraction,
    multiplication,
    division,
    square_root,
    power,
    exponential,
    logarithm,
    anti_logarithm,
    sine,
    cosine,
    tangent,
    arcsine,
    arccosine,
    arctangent,
    rads,
    degs,
    negative,
    factorial
];

export default operations;
    
    
