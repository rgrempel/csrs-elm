declare var JSOG: JSOG;

interface JSOG {
    encode: (input: any) => any;
    decode: (input: any) => any;
    stringify: (input: any) => string;
    parse: (input: string) => any;
}
