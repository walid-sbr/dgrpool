create table users(
-- generated by devise
name text
);

create table var_types(
id serial,
name text,
description text,
impact text,
impact_class text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table journals(
id serial,
name text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table statuses(
id serial,
name text, -- submitted, validated, rejected, integrated
label text,
css_class text,
primary key (id)
);

create table dgrp_statuses(
id serial,
name text,
label text,
css_class text,
description text,
url_mask text,
primary key (id)
);

create table studies(
id serial,
title text,
first_author text,
authors text,
authors_json text,
abstract text,
journal_id int references journals,
volume text,
issue text,
pmid int,
doi text,
year int,
comment text,
description text,
published_at timestamp,
created_at timestamp,
updated_at timestamp,
status_id int references statuses,
pheno_json text,
pheno_mean_json text,
pheno_median_json text,
pheno_sum_json text,
flybase_ref text,
repository_identifiers text,
submitter_id int references users,
validator_id int references users,
primary key (id)
);

create index studies_pmid_idx on studies(pmid);
create index studies_doi_idx on studies(doi);

create table figure_types(
id serial,
name text,
primary key (id)
);

create table figures(
id serial,
study_id int references studies,
phenotype_ids text,
figure_type_id int references figure_types,
attrs_json text,
caption text,
user_id int references users, -- curator id
primary key (id)
);

create table categories(
id serial,
name text,
num int,
description text,
nber_studies int,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table categories_studies(
category_id int references categories,
study_id int references studies
);

create table phenotype_keywords(
id serial,
name text,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);


create table genes( --ensembl_genes
id serial,
name text,
full_name text,
identifier text,
in_vcf bool default false,
synonyms text,
summary_json text,
-- copy table from asap for Flybase genes
primary key (id)
);

create index genes_name_idx on  genes(name);

create table dgrp_lines(
id serial,
name text,
nber_studies int,
nber_phenotypes int,
user_id int references users,
dgrp_status_id int references dgrp_statuses,
fbsn text,
bloomington_id int,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table dgrp_line_genes( -- to confirm
id serial,
dgrp_line_id int references dgrp_lines,
gene_id int references genes,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table dgrp_line_studies(
id serial,
dgrp_line_id int references dgrp_lines,
study_id int references studies,
user_id int references users,
obsolete bool,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table dgrp_line_studies_phenotype_keywords(
dgrp_line_study_id int references dgrp_line_studies,
phenotype_keyword_id int references phenotype_keywords
);

create table ontologies( -- FBcv, FBbt, etc...
id serial,
name text,
tag text,
file_url text, --file url (obo if exists)
format text,
latest_version text, --name or timestamp
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table ontology_terms(
id serial,
ontology_id int references ontologies,
identifier text,
alt_identifiers text,
name text,
description text,
content_json text,
obsolete bool default false,
latest_version text, -- to keep track if it becomes obsolete
related_gene_ids text,
related_pmids text, -- or related_study_ids if we plan to add automatically all the papers that are referenced in the termsthat we map to a given phenotype
node_gene_ids text,
node_term_ids text,
parent_term_ids text,
children_term_ids text,
lineage text,
original bool,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table summary_types(
id serial,
name text,
created_at timestamp,
updated_at timestamp,
primary key (id)
)

create table units(
id serial,
label text,
label_html text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table phenotypes(
id serial,
name text,
study_id int references studies,
description text,
user_id int references users,
obsolete bool,
nber_dgrp_lines int,
nber_sex_female int,
nber_sex_male int,
nber_sex_na int,
sex_by_dgrp text,
is_summary bool,
is_numeric bool,
is_continuous bool,
summary_type_id int references summary_types,
dataset_idx int,
unit_id int references units,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table dgrp_line_studies_phenotypes(
dgrp_line_study_id int references dgrp_line_studies,
phenotype_id int references phenotypes
);

create index dgrp_line_studies_phenotypes_dgrp_line_study_id_idx on  dgrp_line_studies_phenotypes(dgrp_line_study_id);
create index dgrp_line_studies_phenotypes_phenotype_id_idx on  dgrp_line_studies_phenotypes(phenotype_id);

create table ontology_terms_phenotypes(
ontology_term_id int references ontology_terms,
phenotype_id int references phenotypes
);

create table uploads(
id serial,
study_id int references studies,
--type text, -- summary or by_sample
--dataset_id int,
filename text,
version_id int,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table snps(
id serial,
chr text,
pos int,
identifier text,
chr_dm6 text,
pos_dm6 int,
identifier_dm6 text,
ref text,
alt text,
geno_string text,
annots_json text,
//regulatory_annots_json text,
primary key (id)
);

create index identifier_snps on snps(identifier);

--create table genes(
--id serial,
--name text,
--full_name text,
--ensembl_id text,
--summary_json text
--primary key (id)
--);

--create table snp_types(
--id serial,
--name text,
--primary key (id)
--);

--create table snp_impacts(
--id serial,
--name text,
--primary key (id)
--);

create table snp_genes(
id serial,
snp_id int references snps,
gene_id int references genes,
var_type_id int references var_types,
--snp_impact_id int references snp_impacts,
affects_regulatory_region bool,
affects_tf_binding_site bool,
-- best_p_val bool,
-- best_phenotype_id int references phenotypes,
primary key (id)
);

create index snp_genes_gene_id on  gwas_results(gene_id);

create table gwas_results(
id serial,
snp_id int references snps,
phenotype_id int references phenotypes,
sex text,
p_val float,
fdr float,
primary key (id)       
);

 create index gwas_results_phenotype_id_sex on gwas_results(phenotype_id, sex);

create table flybase_alleles(
id serial,
identifier text,
symbol text,
gene_id int references genes,
phenotypes_json text,
primary key (id)
);

create index flybase_alleles_gene_id_idx on flybase_alleles(gene_id);
create index flybase_alleles_identifier_idx on flybase_alleles(identifier);

create table human_orthologs(
id serial,
-- Dmel_gene_ID  Dmel_gene_symbol        Human_gene_HGNC_ID      Human_gene_OMIM_ID      Human_gene_symbol       DIOPT_score     OMIM_Phenotype_IDs      OMIM_Phenotype_IDs[name]
gene_id int references genes,
hgnc_gene_id int,
omim_gene_id int,
human_gene_name text,
diopt_score int,
omim_phenotypes text,
primary key (id)
);

create index human_orthologs_gene_id_idx on human_orthologs(gene_id);

create table organisms(
id serial,
name text,
oma_identifier text,
tax_id int,
genome_source text,
version text,
primary key (id)
);

create table oma_orthologs(
id serial,
gene_id int references genes,
oma_group_id text,
organism_id int references organisms,
ensembl_ids text,
uniprot_ids text,
primary key (id)
);

create index oma_orthologs_gene_id_idx on oma_orthologs(gene_id);
