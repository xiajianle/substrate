(module
	(import "env" "ext_balance" (func $ext_balance (param i32 i32)))
	(import "env" "ext_transfer" (func $ext_transfer (param i32 i32 i32 i32) (result i32)))
	(import "env" "memory" (memory 1 1))

	;; [0, 8) reserved for $ext_balance output

	;; [8, 16) length of the buffer
	(data (i32.const 8) "\08")

	;; [16, inf) zero initialized

	(func $assert (param i32)
		(block $ok
			(br_if $ok
				(get_local 0)
			)
			(unreachable)
		)
	)

	(func (export "deploy"))

	(func (export "call")
		;; Send entire remaining balance to the 0 address.
		(call $ext_balance (i32.const 0) (i32.const 8))

		;; Balance should be encoded as a u64.
		(call $assert
			(i32.eq
				(i32.load (i32.const 8))
				(i32.const 8)
			)
		)

		;; Self-destruct by sending full balance to the 0 address.
		(call $assert
			(i32.eq
				(call $ext_transfer
					(i32.const 16)	;; Pointer to destination address
					(i32.const 8)	;; Length of destination address
					(i32.const 0)	;; Pointer to the buffer with value to transfer
					(i32.const 8)	;; Length of the buffer with value to transfer
				)
				(i32.const 4) ;; ReturnCode::BelowSubsistenceThreshold
			)
		)
	)
)
