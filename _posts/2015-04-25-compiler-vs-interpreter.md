---
layout: post
title:  "通过实例看解释器和编译器的区别"
author: 詹子知(James Zhan)
date:   2015-04-25 23:00:00
meta:   版权所有，转载须声明出处
category: pdl
tags: [javascript, compiler, interpreter]
---

本文将通过一个简单例子来对比一下解释器和编译器的区别。

在实现Compiler（编译器）和Interpreter（解释器）之前，我们需要先选择一种目标语言，这里我们选用计算器语言，它的文法非常简单，而且可以很方便地扩展，除了四则运算之外，如果有需要，我们可以很方便地加入负数，平方，开方，幂，括号及变量等。

本例，为了演示简单，我们的计算器仅支持四则运算，负数和括号。

```
expression : term | expression '+' term | expression '-' term
term : primary_expression | term '*' primary_expression | term '/' primary_expression
primary_expression : DOUBLE_LITERAL | '(' expression ')' | '-' primary_expression
```

在实现Interpreter和Compiler之前，我们都需要先实现语法解析器（Parser），它的主要工作就是把输入的代码字符串转换为AST（抽象语法树），Interpreter和Compiler都是以AST作为输入。

### Parser的实现

Parser的工作主要有两步：

1. 扫描整个代码文本，识别出每个单词，并把它们划分成不同类型的token（其实这个类型可以不需要非常准确，毕竟有些token的类型需要等到Parser真正分析到的时候才可以最终确定）。
2. 按照文法规则把token序列转换为AST。

> 真实情况下的解析器的实现都是边读入代码文本边解析，不会一次性把所有代码文本都读入，它一般都会依赖于Lexer（词法解析器），Parser控制整个解析过程，Lexer按需返回Parser需要的token。
> Lexer在返回token类型的时候可以不需要百分百准确，毕竟有些token的类型需要到了语法解析过程中才可以最终确定。下文要演示的到负号和减号就是这种情况。

```javascript
function parse(code) {
    var tokens = code.split('"').map(function(x, i){
        if (i % 2 === 0){ // not in string
            return x.replace(/([-+*/()])/g, " $1 ");
        } else { // in string
            return x.replace(/\s/g, "#whitespace#");
        }
    }).join('"').trim().split(/\s+/).map(function(x){
        return x.replace(/#whitespace#/g, " ");
    }).map(function(input, i) {
        if (input === '(') {
            return {type: '(', value: '('};
        } else if (input === ')') {
            return {type: ')', vaue: ')'};
        } else if (input === '+' || input === '-') {
            return {type: 'plus', value: input};
        } else if (input === '*' || input === '/') {
            return {type: 'mul', value: input};
        } else if (!isNaN(parseFloat(input))) {
            return {type: 'number', value: parseFloat(input)};
        } else {
            throw new SyntaxError("Unknow token: " + input);
        }
    });
    return parseExpression(tokens);
}
```

```javascript
function parseExpression(tokens) {
    var v1, v2, token;
    v1 = parseTerm(tokens);
    token = tokens.shift();
    if (token === undefined) {
        return v1;
    } else if (token.type === 'plus') {
        v2 = parseExpression(tokens);
        return {type: 'op', value: token.value, v1: v1, v2: v2};
    } else {
        tokens.unshift(token);
        return v1;
    }
}

function parseTerm(tokens){
    var v1, v2, token;
    v1 = parsePrimary(tokens);
    token = tokens.shift();
    if (token === undefined) {
        return v1;
    } else if (token.type === 'mul') {
        v2 = parseTerm(tokens);
        return {type: 'op', value: token.value, v1: v1, v2: v2};
    } else {
        tokens.unshift(token);
        return v1;
    }
}

function parsePrimary(tokens) {
    var token = tokens.shift(), value;
    if (token === undefined) {
        throw new SyntaxError("Primary can't be null.");
    } else if (token.type === 'number') {
        return {type: 'number', value: token.value};
    } else if (token.type === '(') {
        value = parseExpression(tokens);
        token = tokens.shift();
        if (token === undefined || token.type !== ')') {
            throw new SyntaxError("unclosed delimeter till end of file: " + JSON.stringify(token));
        }
        return value;
    } else if (token.value === '-') {
        value = parsePrimary(tokens);
        return {type: 'negative', value: value}
    } else {
        throw new SyntaxError("Unknown token " + JSON.stringify(token) + " in Primary.");
    }
}
```

细心的同学一定注意到，这个代码的实现和前面的文法规则非常神似，其实，在现实中，很少有人直接手写Parser（语法规则简单的语言除外，比如LISP），语法解析的工作我们通常都可以借助工具来做，比较常用的有yacc，AntLR，JavaCC等。


### Interpreter

```javascript
function interpret(ast) {
    var type = ast.type;
    switch (type) {
        case 'number':
            return ast.value;
        case 'negative':
            return -interpret(ast.value);
        case 'op':
            switch (ast.value) {
                case '+':
                    return interpret(ast.v1) + interpret(ast.v2);
                case '-':
                    return interpret(ast.v1) - interpret(ast.v2);
                case '*':
                    return interpret(ast.v1) * interpret(ast.v2);
                case '/':
                    return interpret(ast.v1) / interpret(ast.v2);
                default :
                    throw new EvalError("Unknown operator: " + ast.value);
            }
        default :
            throw new EvalError("Unknown ast node: " + ast);
    }
}
```

Interpreter直接解释执行AST，并返回最终结果。

```javascript
console.log(interpret(parse("3 * -(8 + -2)"))); // => -18
```


### Compiler

```javascript
function compile(ast) {
    var type = ast.type;
    switch (type) {
        case 'number':
            return "ds.push(" + ast.value + ")\n";
        case 'negative':
            return "ds.push(-ds.pop())\n";
        case 'op':
            return compile(ast.v1) + compile(ast.v2) + "ds.push(ds.pop() " + ast.value + " ds.pop())\n";
        default :
            throw new EvalError("Unknown ast node: " + ast);
    }
}
```

Compiler不直接执行AST，而是把AST翻译成目标语言，比如汇编语言或者Java字节码，本例，我们假定我们的目标机器是一个栈式虚拟机，且使用JavaScript兼容的语法。

> 真实的编译器要比本例复杂的多，生成目标代码往往不是一步到位的，一般都会包括中间代码生成，代码优化等相关内容。

```javascript
var assemblyCode = compile(parse("3 * -(8 + -2)")); 
// ds.push(3)
// ds.push(8)
// ds.push(2)
// ds.push(-ds.pop())
// ds.push(ds.pop() + ds.pop())
// ds.push(-ds.pop())
// ds.push(ds.pop() * ds.pop())
```

执行目标语言代码。

```javascript
var vm = (function(){
    var initDs = "var ds = []\n",
        popDs = "\nds.pop()\n";
    return {
        exec: function(code){
            return eval(initDs + code + popDs);
        }
    };
})();

console.log(vm.exec(assemblyCode)); // => -18
```

Compiler vs. Interpreter

从上面的过程中，我们可以看出其实Compiler和Interpreter有很多的相似之处，只不过是目标不一样罢了。其实除了它们都接受AST作为输入之外，它们在AST的遍历方式上一般也是一致的，下面我们就重构一下上面的代码。

```javascript
function travel(ast, visitor) {
    var type = ast.type;
    switch (type) {
        case 'number':
            return visitor.visitNumber(ast.value);
        case 'negative':
            return visitor.visitNegative(travel(ast.value, visitor));
        case 'op':
            return visitor.visitOp(ast.value, travel(ast.v1, visitor), travel(ast.v2, visitor));
        default :
            throw new EvalError("Unknown ast node: " + ast);
    }
}

function interpret(ast) {
    var visitor = {
        visitNumber: function(value) {
            return value;
        },
        visitNegative: function(value) {
            return -value;
        },
        visitOp: function(op, v1, v2) {
            switch (op) {
                case '+':
                    return v1 + v2;
                case '-':
                    return v1 - v2;
                case '*':
                    return v1 * v2;
                case '/':
                    return v1 / v2;
                default :
                    throw new EvalError("Unknown operator: " + ast.value);
            }
        }
    };
    return travel(ast, visitor);
}


function compile(ast) {
    var code = [],
        visitor = {
            visitNumber: function(number) {
                code.push("ds.push(" + number + ")");
            },
            visitNegative: function(value) {
                code.push("ds.push(-ds.pop())");
            },
            visitOp: function(op, v1, v2){
                code.push("ds.push(ds.pop() " + op + " ds.pop())");
            }
        };
    travel(ast, visitor);
    return code.join("\n");
}
```

重构后的代码好像比之前没有什么简化的地方，但是它却把AST的遍历和AST的操作给分离了开来，这样做的好处在于，一旦我们要为AST定义新的行为，只需要实现Visitor即可。比如，下例演示了打印AST的功能。

```javascript
function printAST(ast) {
    var visitor = {
        visitNumber: function(number) {
            return number;
        },
        visitNegative: function(value) {
            return ['-', value];
        },
        visitOp: function(op, v1, v2){
            return [op, v1, v2];
        }
    }, graph = function(node, i) {
        var indent = '';
        for (var j = 0; j < i; j++){
            indent += "\t";
        }
        if (node.forEach && node.map && node.reduce) { //isArray
            var op = node[0];
            console.log(indent, op);
            node.slice(1).forEach(function(e){
                graph(e, i + 1);
            });
        } else {
            console.log(indent, node);
        }
    };
    return graph(travel(ast, visitor), 0);
}

printAST(parse("(2 + 3) * (5 + 6)"));
//   *
//  	 +
//  		 2
//  		 3
//  	 +
//  		 5
//  		 6
```

从这个例子中我们可以看出，Compiler和Interpreter其实并没有很大的不同，它们最大的区别不过是对AST遍历过程中所进行的操作不同罢了。


### 参考资料

1. [完整源代码][1]
2. [lispscript][2]

[1]: https://github.com/jameszhan/prototypes/blob/master/lang/compiler_vs_interpreter.js "详细源码" 
[2]: https://github.com/jameszhan/lispscript "lispscript"