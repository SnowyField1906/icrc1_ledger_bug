export const idlFactory = ({ IDL }) => {
  const Acorn = IDL.Service({
    'acornPrincipal' : IDL.Func([], [IDL.Opt(IDL.Principal)], ['query']),
    'init' : IDL.Func([IDL.Vec(IDL.Nat8)], [], []),
  });
  return Acorn;
};
export const init = ({ IDL }) => { return []; };
