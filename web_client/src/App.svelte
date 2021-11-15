<script>
    import operations from './classes/operations';
    import Operation, { OneOperandOperationRegex, TwoOperandOperationRegex } from './classes/operation';


    let screen = undefined;
    let operation_string = "|";
    
    let current_operator = undefined;

    $: if (screen != undefined) {
        screen.focus();
    }

    const operationUpdate = operation => {
        if (operation instanceof Operation) {
            if (current_operator !== undefined) {
                resetOperation();
            }
            operation_string = operation.getOperationString();
            current_operator = operation;
        }
        screen.focus();
    }

    const resetOperation = () => {
        current_operator.reset();
        current_operator = undefined;
    }


    const screenUpdate = e => {
        const { key } = e;
        if ((!isNaN(key) && key != ".") || key == "-") {
            current_operator.sendDigit(key);
            operation_string = current_operator.getOperationString();
            
        } else if (key === "ArrowLeft" || key === "ArrowRight") {
            current_operator.changeOperand(key === "ArrowLeft" ? -1 : 1);
            operation_string = current_operator.getOperationString();
        } else {
            switch (key) {
                case ".":
                    current_operator.sendDigit(key);
                    operation_string = current_operator.getOperationString();
                    break;
                case "Backspace":
                    current_operator.popDigit();
                    operation_string = current_operator.getOperationString();
                    break;
                case "Enter":
                    current_operator.execute().then(result => {
                        operation_string = result.result;
                        resetOperation();
                    });
                    break;
                case "Escape":
                    if (current_operator !== undefined) {
                        resetOperation();
                    }
                    operation_string = "|";
                    break;
                default:
                    for(let operation of operations) {
                        if(operation.shortcut === key) {
                            operationUpdate(operation);
                            break;
                        }
                    }
                    break;
            }
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


