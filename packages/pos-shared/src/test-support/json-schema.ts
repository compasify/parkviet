// The part of JSON Schema the print document contract uses, so the contract
// test needs no YAML or schema library. An unsupported keyword throws: a
// silently ignored keyword would make the test pass while checking nothing.

export type Schema = Record<string, unknown>;
export type Schemas = Record<string, Schema>;

const KNOWN = new Set([
  '$ref',
  'type',
  'const',
  'enum',
  'required',
  'properties',
  'additionalProperties',
  'items',
  'oneOf',
  'description',
]);

const typeOf = (value: unknown) => {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  return typeof value;
};

function matchesType(value: unknown, type: string): boolean {
  if (type === 'integer') return Number.isInteger(value);
  return typeOf(value) === type;
}

export function validate(value: unknown, schema: Schema, schemas: Schemas, path = '$'): string[] {
  for (const key of Object.keys(schema))
    if (!KNOWN.has(key)) throw new Error(`Unsupported schema keyword ${key} at ${path}`);

  if (typeof schema.$ref === 'string') {
    const name = schema.$ref.split('/').at(-1) ?? '';
    const target = schemas[name];
    if (!target) throw new Error(`Unknown schema ${schema.$ref}`);
    return validate(value, target, schemas, path);
  }
  if (Array.isArray(schema.oneOf)) {
    const passing = (schema.oneOf as Schema[]).filter(
      (option) => validate(value, option, schemas, path).length === 0,
    );
    return passing.length === 1 ? [] : [`${path}: matched ${passing.length} of oneOf`];
  }
  const errors: string[] = [];
  if ('const' in schema && value !== schema.const)
    errors.push(`${path}: not ${String(schema.const)}`);
  if (Array.isArray(schema.enum) && !schema.enum.includes(value))
    errors.push(`${path}: ${String(value)} is not allowed`);
  if (schema.type !== undefined) {
    const types = Array.isArray(schema.type) ? (schema.type as string[]) : [schema.type as string];
    if (!types.some((type) => matchesType(value, type)))
      return [`${path}: expected ${types.join('|')}, got ${typeOf(value)}`];
  }
  if (typeOf(value) === 'object') {
    const record = value as Record<string, unknown>;
    const properties = (schema.properties ?? {}) as Schemas;
    for (const key of (schema.required ?? []) as string[])
      if (!(key in record)) errors.push(`${path}.${key}: missing`);
    for (const [key, item] of Object.entries(record)) {
      const child = properties[key];
      if (child) errors.push(...validate(item, child, schemas, `${path}.${key}`));
      else if (schema.additionalProperties === false) errors.push(`${path}.${key}: not allowed`);
    }
  }
  if (Array.isArray(value) && schema.items)
    value.forEach((item, index) => {
      errors.push(...validate(item, schema.items as Schema, schemas, `${path}[${index}]`));
    });
  return errors;
}
