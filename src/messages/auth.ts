import { BigNumberish } from "ethers";

interface AuthToken {
  expiry: BigNumberish;
  functionCall: FunctionCall;
}

interface FunctionCall {
  functionSignature: string;
  target: string;
  caller: string;
  parameters: string;
}

// The named list of all type definitions
const AuthMessageTypes = {
  FunctionCall: [
    { name: "functionSignature", type: "bytes4" },
    { name: "target", type: "address" },
    { name: "caller", type: "address" },
    { name: "parameters", type: "bytes" },
  ],
  AuthToken: [
    { name: "expiry", type: "uint256" },
    { name: "functionCall", type: "FunctionCall" },
  ],
};

export { AuthMessageToken, FunctionCall, AuthMessageTypes };
