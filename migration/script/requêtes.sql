-- afficher le nom scientifique, le nom commun et le nom de la famille des espèces
SELECT
  scientific_name,
  common_name,
  name
FROM
  species
  JOIN family ON family_id = family.id;
-- c'est la condition de jointure (pour rassembler les résultats)
  -- afficher les espèces pour lesquelles il existe au moins une variété avec une amertume de 5SELECT DISTINCT species.*
SELECT
  DISTINCT species.*
FROM
  species
  JOIN variety ON variety.species_id = species.id
WHERE
  bitterness = 5;
-- afficher le nom de la plantation et le libellé des rangées concernées (une ligne par rangée)
SELECT
  field.name,
  row.label
FROM
  row
  JOIN field ON field.id = field_id
  JOIN variety ON variety.id = row.variety_id
WHERE
  bitterness = 5;
-- Aïe, ça fait plein de lignes :see_no_evil: J'ai entendu parler d'une fonction array_agg qui permet de représenter un ensemble de valeurs sous forme de tableau, on pourrait peut-être grouper par plantation et ne présenter qu'une ligne par plantation ?
SELECT
  field.name,
  array_agg(row.label)
FROM
  row
  JOIN field ON field.id = field_id
  JOIN variety ON variety.id = row.variety_id
WHERE
  bitterness = 5
GROUP BY
  field.name;
-- Les clients de l'orangeraie ont tendance à dire que leurs clémentines ne sont pas juteuses :angry: Mais qu'est-ce qu'ils en savent, hein, d'abord ? Bon, on devrait bien pouvoir écrire une requête pour déterminer une bonne fois pour toute quelles familles ne contiennent aucune espèce ayant une jutosité moyenne supérieure à la moyenne (2.5, vu qu'on les note de 0 à 5).
select
  family.name
from
  family
where
  family.id not in (
    select
      distinct family_id
    from
      species
    where
      species.id in (
        select
          species_id
        from
          variety
        group by
          species.id
        having
          avg(juiciness) > 2.5
      )
  );
-- Demande urgente d'un gestionnaire : il lui faudrait la liste des plantations qui produisent de la mandarine, peu importe l'espèce. Même si ce n'est que sur un rang dans une petite plantation isolée, il faut qu'elle y figure.
select distinct field.name, field.location
from field
where field.id in (
    select field_id
    from row
    where variety_id in (
        select variety.id
        from variety
        where species_id in (
            select species.id
            from species
            where family_id in (
                select family.id
                from family
                where name = 'mandarine'
              )
          )
      )
  );


-- En parlant de lisibilité, je vous propose de réécrire la requête des plantations de mandarine avec des jointures.
select distinct field.name, field.location
from field
join row on row.field_id = field.id
join variety on row.variety_id = variety.id
join species on variety.species_id = species.id
join family on family.id = species.family_id
where family.name = 'mandarine';