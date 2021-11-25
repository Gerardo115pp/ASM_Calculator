import AsmMath.operations as asm_math
import http.server as http
from socket import socket
from typing import Tuple, Dict
import json


class OperationsRouteHandler(http.BaseHTTPRequestHandler):
    
    @classmethod
    def run(cls, host:str, port:int):
        print(f"listing on -> {host}:{port}")
        listener = http.HTTPServer((host ,port), cls)
        listener.serve_forever()
    
    
    def __init__(self, request:socket, client_address:Tuple[str, int], server: http.HTTPServer):
        #before request gets handled
        print(f"{client_address} connected")
        self.operations = {
            "+": asm_math.addition,
            "-": asm_math.subtraction,
            "*": asm_math.multiplication,
            "/": asm_math.division,
            "sqrt": asm_math.squareRoot,
            "^": asm_math.power,
            "log": asm_math.logarithm,
            "antilog": asm_math.antilog,
            "sin": asm_math.sin,
            "cos": asm_math.cos,
            "tan": asm_math.tan,
            "arcsin": asm_math.arcsin,
            "arccos": asm_math.arccos,
            "arctan": asm_math.arctan,
            "rads": asm_math.degreesToRadians,
            "degs": asm_math.radiansToDegrees,
            "-x": asm_math.changeSign,
            "exp": asm_math.exponential,
            "!": asm_math.factorial,
        }
        
        super().__init__(request, client_address, server) # request gets handled
        # after request gets handled  
        
    def do_POST(self):
        return self.route()
        
    def do_GET(self):
        return self.route()    
    
    def do_OPTIONS(self):
        """
            support browser preflight requests
        """
        
        self.setCorsPolicy()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"message": "ok"}).encode())
    
    def getServerAddress(self) -> Tuple[str, int]:
        return self.server_host, self.server_port
    
    def validateRequestForm(self, body:Dict) -> bool:
        is_valid = True
        if "operation" not in body:
            is_valid = False
            
        elif body["operation"] not in self.operations:
            is_valid = False
        
        if "type" not in body:
            return False# we cant continue validating the request if it is not valid
        
        if "a" not in body:
            is_valid = False
        
        if body["type"] != 1:
            if "b" not in body:
                is_valid = False
                    
        return is_valid
        
        
    def route(self):
        self.protocol_version = "HTTP/1.1"
    
        if self.path == "/eval":
            # expects a body with json e.g: {"operation": "+", "a": 1, "b": 2}
            body = self.rfile.read(int(self.headers['Content-Length']))
            request = json.loads(body)
            print("pendejpo")
            print(f"evaluating {request}")
            
            if not self.validateRequestForm(request):
                print("invalid request")
                self.send_response(400, "invalid request")
                self.setCorsPolicy()
                self.end_headers()
                return
            
            # check if is a two operand operation
            print(f"(a){type(request['a']).__name__}\t(b){type(request['b']).__name__}")
            if request["type"] == 1:
                a = float(request["a"]) if "." in request["a"] else int(request["a"])
                result = self.operations[request["operation"]](a)
            else:
                a = float(request["a"]) if "." in request["a"] else int(request["a"])
                b = float(request["b"]) if "." in request["b"] else int(request["b"])
                result = self.operations[request["operation"]](a, b)
            
            print(f"result: {result}")
            response = json.dumps({"result": result}).encode()
            
            self.send_response(200) # writes <status code> <reason>
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", len(response))
            self.setCorsPolicy() # set CORS to allow cross origin requests
            self.end_headers() # blank line, end of headers
            
            self.wfile.write(response) # data section
            
            
    def setCorsPolicy(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        
    

        
        

if __name__ == "__main__":
    OperationsRouteHandler.run("127.0.0.1", 7001)