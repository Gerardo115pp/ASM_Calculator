<script>
    import { each } from 'svelte/internal';
import Operation, { operation_types, OneOperandOperationRegex, TwoOperandOperationRegex } from './classes/operation';


    let screen = undefined;
    let operation_string = "0";
    let operations = [
        new Operation(operation_types.TWO_OPERAND, "+", "+"),
        new Operation(operation_types.TWO_OPERAND, "-", "-"),
        new Operation(operation_types.TWO_OPERAND, "*", "*"),
        new Operation(operation_types.TWO_OPERAND, "/", "/"),
        new Operation(operation_types.ONE_OPERAND, "sqrt", "√x"),
        new Operation(operation_types.TWO_OPERAND, "^", "xᵃ"),
        new Operation(operation_types.TWO_OPERAND, "log", "logᵃ"),
        new Operation(operation_types.ONE_OPERAND, "antilog", "log⁻¹"),
        new Operation(operation_types.ONE_OPERAND, "sin", "sin"),
        new Operation(operation_types.ONE_OPERAND, "cos", "cos"),
        new Operation(operation_types.ONE_OPERAND, "tan", "tan"),
        new Operation(operation_types.ONE_OPERAND, "arcsin", "sin⁻¹"),
        new Operation(operation_types.ONE_OPERAND, "arccos", "cos⁻¹"),
        new Operation(operation_types.ONE_OPERAND, "arctan", "tan⁻¹"),
        new Operation(operation_types.ONE_OPERAND, "rads", "rad"),
        new Operation(operation_types.ONE_OPERAND, "degs", "deg"),
        new Operation(operation_types.ONE_OPERAND, "-x", "-x")
    ]
    let current_operator = {
        operation: undefined,
        operator_index: -1
    }

    $: if (screen != undefined) {
        screen.focus();
    }

    const operationUpdate = operation => {
        if (operation instanceof Operation) {
            let new_operation_string = operation_string;

            current_operator.operation = operation;
            new_operation_string = new_operation_string === "0" ? "" : new_operation_string; // if the operation string is 0, then clear it so that index of operator is 0 in case of a one operand operation
            current_operator.operator_index = new_operation_string.length;
            new_operation_string = new_operation_string + operation.operator; 
            operation_string = new_operation_string; // change the pointer to operation_string so svelte rerenders the screen
        }
        screen.focus();
    }

    const resetOperation = () => {
        current_operator = {
            operation: undefined,
            operator_index: -1
        }
    }


    const screenUpdate = e => {
        const { key } = e;
        let new_operation_string = operation_string;

        if (!isNaN(key) && key != " ") {
            new_operation_string = operation_string === "0" ? key : operation_string + key;
        } 

        switch (key) {
            case ".":
                new_operation_string += ".";
                break;
            case "Backspace":
                if (operation_string.length > 0) {
                    new_operation_string = operation_string.slice(0, -1);
                }
                break;
            case "Enter":
                if (operation_string.length > 0) {
                    console.log(operation_string);
                    current_operator.operation.execute(operation_string).then(result => {
                        operation_string = result.result
                        resetOperation();
                    });
                    return;
                }
                break;
            case "Escape":
                new_operation_string = "0";
                resetOperation();
                break;
            default:
                break;
        }
        
        let syntaxChecker = TwoOperandOperationRegex;
        if (current_operator.operation != undefined) {
            syntaxChecker = current_operator.operation.type == 1 ? OneOperandOperationRegex : TwoOperandOperationRegex;
        }

        if (syntaxChecker.test(new_operation_string)) {
            operation_string = new_operation_string;
        } else {
            console.log(`Syntax error: ${new_operation_string}`);
        }
    }


</script>



<div id="app-container">
    <header id="asm-calculator-header">
        <h1>ASM Calculator</h1>
    </header>
    <div id="asm-calculator-container">
        <div on:click={() => screen.focus()} id="asmc-screen">
            <div on:keyup={screenUpdate}  tabindex="0" bind:this={screen} id="asmc-screen-display">{operation_string}</div>
        </div>
        <div id="asmc-keypad">
            {#each operations as operation}
                <div on:click={() => operationUpdate(operation)} class="calc-key" id="asmc-key-{operation.operator}">{operation.operation_label}</div>
            {/each}
        </div>
    </div>
</div>

<style>
    @import url('https://fonts.googleapis.com/css2?family=Courgette&family=Dosis:wght@200;400;500&family=Nunito+Sans:wght@200;300&family=Special+Elite&display=swap');

    :root {
        --theme-color: #00d9ff;
        --background-color: #f5fbff;
        --screen-color: #9adac7;
        --screen-foreground-color: #06517c;
        --key-fg: #ffffff;
        --key-bg: #06517c;
    }

    :global(body) {
        overflow-y: hidden;
        background-color: var(--background-color);
        font-family: 'Nunito Sans', sans-serif;
        margin: 0;
        padding: 0;
        user-select: none;
    }

    :global(h1, h2, h3, h4, h5, h6) {
        margin: 0;
        padding: 0;
    }

    #asm-calculator-header {
        font-family: 'Special Elite', cursive;
        color: var(--theme-color);
        font-size: 1.4rem;
        padding: 2vh 2vw;
        text-align: center;
    }

    #asm-calculator-container {
        width: 60%;
        margin: 0 auto;
        border-left: 1px solid var(--theme-color);
        border-right: 1px solid var(--theme-color);
        height: 91.9vh;
        box-shadow: 0 0.5vh 0.5vh 0 rgba(0, 0, 0, 0.2);
    }

    #asmc-screen {
        font-family: 'Dosis', sans-serif;
        display: flex;
        background-color: var(--screen-color);
        width: 90%;
        height: 20vh;
        font-size: 2.5rem;
        color: var(--screen-foreground-color);
        margin: 0 auto;
        justify-content: center;
        align-items: center;
        border-radius: 0.5vh;
        border: .1em solid var(--theme-color);
    }

    #asmc-screen-display {
        outline: none;
    }

    #asmc-keypad {
        display: flex;
        width: 90%;
        height: 60vh;
        font-size: 1.5rem;
        flex-wrap: wrap;
        flex-shrink: 0;
        flex-grow: 0;
        justify-content: flex-start;
        align-items: flex-start;
        align-content: flex-start;
        margin: 5vh auto;
    }

    .calc-key {
        font-family: 'Dosis', sans-serif;
        cursor: pointer;
        display: flex;
        width: 10vh;
        height: 4vh;
        background-color: var(--key-bg);
        font-size: 1.5rem;
        color: var(--key-fg);
        border-radius: 0.5vh;
        font-size: 1.3em    ;
        justify-content: center;
        align-items: center;
        margin: 1vh .6vw;
    }
</style>


