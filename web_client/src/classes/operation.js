export const operation_types = {
    "ONE_OPERAND": 1,
    "TWO_OPERAND": 2
}

export const TwoOperandOperationRegex = /^[\d\.]{1,9}(\s.{1,10}\s[\d\.]{0,9})?$/
export const OneOperandOperationRegex = /^.{1,10}\s[\d\.]{0,9}$/

class Operation {
    constructor(type, operator, operation_label) {
        this.type = type;
        this.operator = type === operation_types.ONE_OPERAND ? `${operator} ` : ` ${operator} `;
        this.operation_label = operation_label;
    }

    parseOperands(expression) {
        let operands = expression.split(this.operator);
        operands = operands.filter(operand => operand !== "");
        
        if ( operands.length > this.type ) {
            console.log(operands);
            throw new Error(`Invalid expression (${expression}) produced operands ${operands}`);
        }

        return operands;
    }

    execute(expression) {
        const operands = this.parseOperands(expression);
        const request_body = {
            "operation": this.operator.trim(),
            "type": this.type,
            "a": operands[0]
        }

        if ( this.type === operation_types.TWO_OPERAND ) {
            request_body.b = operands[1];
        }
        console.log(JSON.stringify(request_body));
        const request = new Request(`http://127.0.0.1:7001/eval`, {method: "POST", body: JSON.stringify(request_body)});
        return fetch(request).then(response => response.json());
    }

}

export default Operation;