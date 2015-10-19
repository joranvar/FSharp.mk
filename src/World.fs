open FsCheck

[<EntryPoint>]
let main _ = printfn "%s World" FirstWord.word; Check.Quick (fun s -> s = s); 0
