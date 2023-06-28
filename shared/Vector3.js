"use strict";
// Object.defineProperty(exports, "__esModule", { value: true });
// exports.Vector3 = void 0;
var Vector3 = /** @class */ (function () {
    function Vector3(x, y, z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    Vector3.create = function (v1) {
        if (typeof v1 === 'number')
            return new Vector3(v1, v1, v1);
        return new Vector3(v1.x, v1.y, v1.z);
    };
    /**
     * Creates a vector from an array of numbers
     * @param primitive An array of numbers (usually returned by a native)
     * @example ```ts
     * const entityPos = Vector3.fromArray(GetEntityCoords(entity))
     * ```
     */
    Vector3.fromArray = function (primitive) {
        return new Vector3(primitive[0], primitive[1], primitive[2]);
    };
    /**
     * Creates an array of vectors from an array number arrays
     * @param primitives A multi-dimensional array of number arrays
     * @example ```ts
     * const [forward, right, up, position] = Vector3.fromArrays(GetEntityMatrix(entity))
     * ```
     */
    Vector3.fromArrays = function (primitives) {
        return primitives.map(function (prim) { return new Vector3(prim[0], prim[1], prim[2]); });
    };
    Vector3.clone = function (v1) {
        return Vector3.create(v1);
    };
    Vector3.add = function (v1, v2) {
        if (typeof v2 === 'number')
            return new Vector3(v1.x + v2, v1.y + v2, v1.z + v2);
        return new Vector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
    };
    Vector3.subtract = function (v1, v2) {
        if (typeof v2 === 'number')
            return new Vector3(v1.x - v2, v1.y - v2, v1.z - v2);
        return new Vector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
    };
    Vector3.multiply = function (v1, v2) {
        if (typeof v2 === 'number')
            return new Vector3(v1.x * v2, v1.y * v2, v1.z * v2);
        return new Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
    };
    Vector3.divide = function (v1, v2) {
        if (typeof v2 === 'number')
            return new Vector3(v1.x / v2, v1.y / v2, v1.z / v2);
        return new Vector3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);
    };
    Vector3.dotProduct = function (v1, v2) {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
    };
    Vector3.crossProduct = function (v1, v2) {
        var x = v1.y * v2.z - v1.z * v2.y;
        var y = v1.z * v2.x - v1.x * v2.z;
        var z = v1.x * v2.y - v1.y * v2.x;
        return new Vector3(x, y, z);
    };
    Vector3.normalize = function (v) {
        return Vector3.divide(v, v.length);
    };
    Vector3.prototype.clone = function () {
        return new Vector3(this.x, this.y, this.z);
    };
    /**
     * The product of the Euclidean magnitudes of this and another Vector3.
     *
     * @param v Vector3 to find Euclidean magnitude between.
     * @returns Euclidean magnitude with another vector.
     */
    Vector3.prototype.distanceSquared = function (v) {
        var w = this.subtract(v);
        return Vector3.dotProduct(w, w);
    };
    /**
     * The distance between two Vectors.
     *
     * @param v Vector3 to find distance between.
     * @returns Distance between this and another vector.
     */
    Vector3.prototype.distance = function (v) {
        return Math.sqrt(this.distanceSquared(v));
    };
    Object.defineProperty(Vector3.prototype, "normalize", {
        get: function () {
            return Vector3.normalize(this);
        },
        enumerable: false,
        configurable: true
    });
    Vector3.prototype.crossProduct = function (v) {
        return Vector3.crossProduct(this, v);
    };
    Vector3.prototype.dotProduct = function (v) {
        return Vector3.dotProduct(this, v);
    };
    Vector3.prototype.add = function (v) {
        return Vector3.add(this, v);
    };
    Vector3.prototype.subtract = function (v) {
        return Vector3.subtract(this, v);
    };
    Vector3.prototype.multiply = function (v) {
        return Vector3.multiply(this, v);
    };
    Vector3.prototype.divide = function (v) {
        return Vector3.divide(this, v);
    };
    Vector3.prototype.toArray = function () {
        return [this.x, this.y, this.z];
    };
    Vector3.prototype.replace = function (v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
    };
    Object.defineProperty(Vector3.prototype, "length", {
        get: function () {
            return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
        },
        enumerable: false,
        configurable: true
    });
    return Vector3;
}());
// exports.Vector3 = Vector3;
