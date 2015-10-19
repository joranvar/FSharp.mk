open FsCheck

[<EntryPoint>]
let main _ = Check.Quick (fun x -> x = x); 0
