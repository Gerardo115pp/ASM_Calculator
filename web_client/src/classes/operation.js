export const operation_types = {
    "ONE_OPERAND": 1,
    "TWO_OPERAND": 2
}

export const TwoOperandOperationRegex = /^[\d\.]{1,9}(\s.{1,10}\s[\d\.]{0,9})?$/
export const OneOperandOperationRegex = /^.{1,10}\s[\d\.]{0,9}$/

class Operation {
    empty_operand = "?";

    constructor(type, operator, operation_label) {
        this.type = type;
        this.operator = type === operation_types.ONE_OPERAND ? `${operator} ` : ` ${operator} `;
        this.operation_label = operation_label;
        this.operands = {
            "a": "?",
            "b": "?"
        }
        this.current_operand_index = 0;
        this.operation_format = undefined;
        this.shortcut = this.operator.trim();
    }

    changeOperand = step => {
        const max_operands = Object.keys(this.operands).length;
        this.current_operand_index = (this.current_operand_index + step) % max_operands;
    }

    execute() {
        const request_body = {
            ...this.operands,
            "operation": this.operator.trim(),
            "type": this.type
        };


        console.log(JSON.stringify(request_body));
        const request = new Request(`http://127.0.0.1:7001/eval`, {method: "POST", body: JSON.stringify(request_body)});
        return fetch(request).then(response => response.json());
    }

    getOperationString = () => {
        let expression = this.type === operation_types.ONE_OPERAND ? `${this.operator}${this.operands.a}` : `${this.operands.a}${this.operator}${this.operands.b}`;
        if (this.operation_format !== undefined) {
            // parse operation_format, e.g "{a} + {b}" and replace {a} and {b} with operands
            expression = this.operation_format;
            Object.keys(this.operands).forEach(operand => {
                expression = expression.replace(`{${operand}}`, this.operands[operand]);
            });
        }
        return expression;
    };

    popDigit = () => {
        let operand = Object.keys(this.operands)[this.current_operand_index];
        if (this.operands[operand].length > 0) {
            this.operands[operand] = this.operands[operand].slice(0, -1);
            this.operands[operand] = this.operands[operand].length === 0 ? this.empty_operand : this.operands[operand];
        }
    }

    reset = () => {
        this.operands.a = this.empty_operand;
        this.operands.b = this.empty_operand;
    }

    sendDigit = digit => {
        let operand = Object.keys(this.operands)[this.current_operand_index];
        this.operands[operand] = this.operands[operand] === this.empty_operand ? digit : this.operands[operand] + digit;
    }


}

export default Operation;