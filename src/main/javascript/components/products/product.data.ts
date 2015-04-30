module CSRS {
    export interface IProductGroup {
        id: number;
        productGroupProducts: Array<IProductGroupProduct>;
    }

    export interface IProductGroupProduct {
        id: number;
        productGroup: IProductGroup;
        product: IProduct;
    }

    export interface IProduct {
        id: number;
        code: string;
        productPrereqRequires: Array<IProductPrereq>;
        productPrereqRequiredBy: Array<IProductPrereq>;
        productVariants: Array<IProductVariant>;
    }

    export interface IProductPrereq {
        id: number;
        product: IProduct;
        requiresProduct: IProduct;
    }

    export interface IProductVariant {
        id: number;
        productVariantPrices: Array<IProductVariantPrice>;
        productVariantValues: Array<IProductVariantValue>;
    }

    export interface IProductVariantPrice {
        id: number;
        productVariant: IProductVariant;
        priceInCents: number;
        threeYearReductionInCents: number;
        validFrom: number; // milliseconds since epoch
    }

    export interface IProductVariantValue {
        id: number;
        productValue: IProductValue;
    }

    export interface IProductValue {
        id: number;
        code: string;
        productValueImpliedBy: Array<IProductValueImplication>;
        productValueImplies: Array<IProductValueImplication>;
        productVariable: IProductVariable;
    }

    export interface IProductValueImplication {
        id: number;
        productValue: IProductValue;
        impliesProductValue: IProductValue;
    }

    export interface IProductVariable {
        id: number;
        code: string;
        productValues: Array<IProductValue>;
        impliedBy: IProductVariable;
    }
}
