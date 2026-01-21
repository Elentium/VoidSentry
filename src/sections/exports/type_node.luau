export type typeNode = {
	name: string,
	bytes: number | (value: any) -> number,

	write: (b: buffer, offset: number, value: any) -> number,
	read: (b: buffer, offset: number) -> (any, number),
}
return {}
