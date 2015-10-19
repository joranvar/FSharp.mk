module Question

open System.IO
open System.Runtime.Serialization.Json

let toJson<'t> (value:'t) =
  use stream = new MemoryStream ()
  (new DataContractJsonSerializer (typedefof<'t>)).WriteObject (stream, value)
  stream.ToArray () |> System.Text.Encoding.ASCII.GetString

let question = "How" |> toJson
