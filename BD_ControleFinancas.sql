PGDMP      %                }            ControleFinancas    17.4    17.4 L               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false                        0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            !           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            "           1262    16423    ControleFinancas    DATABASE     x   CREATE DATABASE "ControleFinancas" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'pt-BR';
 "   DROP DATABASE "ControleFinancas";
                     postgres    false            �            1255    16528    fn_prevent_categoria_delete()    FUNCTION     �  CREATE FUNCTION public.fn_prevent_categoria_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    transacoes_existem INTEGER;
BEGIN
    SELECT COUNT(*) INTO transacoes_existem FROM Transacao WHERE id_categoria = OLD.id_categoria;
    IF transacoes_existem > 0 THEN
        RAISE EXCEPTION 'Não é possível deletar categoria que possui transações associadas.';
    END IF;
    RETURN OLD;
END;
$$;
 4   DROP FUNCTION public.fn_prevent_categoria_delete();
       public               postgres    false            �            1255    16526    fn_update_ultima_atualizacao()    FUNCTION     �   CREATE FUNCTION public.fn_update_ultima_atualizacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.ultima_atualizacao := NOW();
    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.fn_update_ultima_atualizacao();
       public               postgres    false            �            1255    16524    fn_valor_positivo()    FUNCTION     �   CREATE FUNCTION public.fn_valor_positivo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.valor < 0 THEN
        NEW.valor := ABS(NEW.valor);
    END IF;
    RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.fn_valor_positivo();
       public               postgres    false            �            1259    16447 	   categoria    TABLE     (  CREATE TABLE public.categoria (
    id_categoria integer NOT NULL,
    nome character varying(100) NOT NULL,
    tipo character varying(10) NOT NULL,
    CONSTRAINT categoria_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['receita'::character varying, 'despesa'::character varying])::text[])))
);
    DROP TABLE public.categoria;
       public         heap r       postgres    false            �            1259    16446    categoria_id_categoria_seq    SEQUENCE     �   CREATE SEQUENCE public.categoria_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.categoria_id_categoria_seq;
       public               postgres    false    222            #           0    0    categoria_id_categoria_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.categoria_id_categoria_seq OWNED BY public.categoria.id_categoria;
          public               postgres    false    221            �            1259    16434    conta    TABLE     �   CREATE TABLE public.conta (
    id_conta integer NOT NULL,
    id_usuario integer NOT NULL,
    nome_banco character varying(100),
    tipo_conta character varying(50),
    saldo_inicial numeric(12,2) DEFAULT 0
);
    DROP TABLE public.conta;
       public         heap r       postgres    false            �            1259    16433    conta_id_conta_seq    SEQUENCE     �   CREATE SEQUENCE public.conta_id_conta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.conta_id_conta_seq;
       public               postgres    false    220            $           0    0    conta_id_conta_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.conta_id_conta_seq OWNED BY public.conta.id_conta;
          public               postgres    false    219            �            1259    16455 	   transacao    TABLE     �  CREATE TABLE public.transacao (
    id_transacao integer NOT NULL,
    id_conta integer NOT NULL,
    id_categoria integer NOT NULL,
    data date NOT NULL,
    valor numeric(12,2) NOT NULL,
    descricao text,
    tipo character varying(10) NOT NULL,
    CONSTRAINT transacao_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['receita'::character varying, 'despesa'::character varying])::text[])))
);
    DROP TABLE public.transacao;
       public         heap r       postgres    false            �            1259    16519    despesas_por_mes_e_categoria    VIEW       CREATE VIEW public.despesas_por_mes_e_categoria AS
 SELECT date_trunc('month'::text, (t.data)::timestamp with time zone) AS mes_ano,
    c.nome AS categoria,
    sum(t.valor) AS total_despesas
   FROM (public.transacao t
     JOIN public.categoria c ON ((t.id_categoria = c.id_categoria)))
  WHERE ((c.tipo)::text = 'despesa'::text)
  GROUP BY (date_trunc('month'::text, (t.data)::timestamp with time zone)), c.nome
  ORDER BY (date_trunc('month'::text, (t.data)::timestamp with time zone)) DESC, (sum(t.valor)) DESC;
 /   DROP VIEW public.despesas_por_mes_e_categoria;
       public       v       postgres    false    224    224    222    222    222    224            �            1259    16534    lembrete_financeiro    TABLE     �  CREATE TABLE public.lembrete_financeiro (
    id_lembrete integer NOT NULL,
    id_usuario integer NOT NULL,
    titulo character varying(100) NOT NULL,
    descricao text,
    data_lembrete date NOT NULL,
    recorrente boolean DEFAULT false,
    frequencia character varying(20),
    CONSTRAINT lembrete_financeiro_frequencia_check CHECK (((frequencia)::text = ANY ((ARRAY['mensal'::character varying, 'anual'::character varying, 'semanal'::character varying])::text[])))
);
 '   DROP TABLE public.lembrete_financeiro;
       public         heap r       postgres    false            �            1259    16533 #   lembrete_financeiro_id_lembrete_seq    SEQUENCE     �   CREATE SEQUENCE public.lembrete_financeiro_id_lembrete_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.lembrete_financeiro_id_lembrete_seq;
       public               postgres    false    233            %           0    0 #   lembrete_financeiro_id_lembrete_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.lembrete_financeiro_id_lembrete_seq OWNED BY public.lembrete_financeiro.id_lembrete;
          public               postgres    false    232            �            1259    16493    metafinanceira    TABLE     �   CREATE TABLE public.metafinanceira (
    id_meta integer NOT NULL,
    id_usuario integer NOT NULL,
    nome character varying(100) NOT NULL,
    valor_objetivo numeric(12,2),
    data_limite date
);
 "   DROP TABLE public.metafinanceira;
       public         heap r       postgres    false            �            1259    16492    metafinanceira_id_meta_seq    SEQUENCE     �   CREATE SEQUENCE public.metafinanceira_id_meta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.metafinanceira_id_meta_seq;
       public               postgres    false    228            &           0    0    metafinanceira_id_meta_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.metafinanceira_id_meta_seq OWNED BY public.metafinanceira.id_meta;
          public               postgres    false    227            �            1259    16475 	   orcamento    TABLE       CREATE TABLE public.orcamento (
    id_orcamento integer NOT NULL,
    id_usuario integer NOT NULL,
    id_categoria integer NOT NULL,
    mes integer,
    ano integer,
    valor_limite numeric(12,2),
    CONSTRAINT orcamento_mes_check CHECK (((mes >= 1) AND (mes <= 12)))
);
    DROP TABLE public.orcamento;
       public         heap r       postgres    false            �            1259    16474    orcamento_id_orcamento_seq    SEQUENCE     �   CREATE SEQUENCE public.orcamento_id_orcamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.orcamento_id_orcamento_seq;
       public               postgres    false    226            '           0    0    orcamento_id_orcamento_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.orcamento_id_orcamento_seq OWNED BY public.orcamento.id_orcamento;
          public               postgres    false    225            �            1259    16504    parcela    TABLE     �   CREATE TABLE public.parcela (
    id_transacao integer NOT NULL,
    n_parcela integer NOT NULL,
    valor_parcela numeric(12,2),
    data_vencimento date
);
    DROP TABLE public.parcela;
       public         heap r       postgres    false            �            1259    16515 %   total_receitas_despesas_por_categoria    VIEW     (  CREATE VIEW public.total_receitas_despesas_por_categoria AS
 SELECT c.nome AS categoria,
    c.tipo,
    sum(t.valor) AS total_valor
   FROM (public.transacao t
     JOIN public.categoria c ON ((t.id_categoria = c.id_categoria)))
  GROUP BY c.nome, c.tipo
  ORDER BY c.tipo, (sum(t.valor)) DESC;
 8   DROP VIEW public.total_receitas_despesas_por_categoria;
       public       v       postgres    false    224    222    222    224    222            �            1259    16454    transacao_id_transacao_seq    SEQUENCE     �   CREATE SEQUENCE public.transacao_id_transacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.transacao_id_transacao_seq;
       public               postgres    false    224            (           0    0    transacao_id_transacao_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.transacao_id_transacao_seq OWNED BY public.transacao.id_transacao;
          public               postgres    false    223            �            1259    16425    usuario    TABLE     �   CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    senha character varying(100) NOT NULL
);
    DROP TABLE public.usuario;
       public         heap r       postgres    false            �            1259    16424    usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuario_id_usuario_seq;
       public               postgres    false    218            )           0    0    usuario_id_usuario_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;
          public               postgres    false    217            Q           2604    16450    categoria id_categoria    DEFAULT     �   ALTER TABLE ONLY public.categoria ALTER COLUMN id_categoria SET DEFAULT nextval('public.categoria_id_categoria_seq'::regclass);
 E   ALTER TABLE public.categoria ALTER COLUMN id_categoria DROP DEFAULT;
       public               postgres    false    222    221    222            O           2604    16437    conta id_conta    DEFAULT     p   ALTER TABLE ONLY public.conta ALTER COLUMN id_conta SET DEFAULT nextval('public.conta_id_conta_seq'::regclass);
 =   ALTER TABLE public.conta ALTER COLUMN id_conta DROP DEFAULT;
       public               postgres    false    220    219    220            U           2604    16537    lembrete_financeiro id_lembrete    DEFAULT     �   ALTER TABLE ONLY public.lembrete_financeiro ALTER COLUMN id_lembrete SET DEFAULT nextval('public.lembrete_financeiro_id_lembrete_seq'::regclass);
 N   ALTER TABLE public.lembrete_financeiro ALTER COLUMN id_lembrete DROP DEFAULT;
       public               postgres    false    233    232    233            T           2604    16496    metafinanceira id_meta    DEFAULT     �   ALTER TABLE ONLY public.metafinanceira ALTER COLUMN id_meta SET DEFAULT nextval('public.metafinanceira_id_meta_seq'::regclass);
 E   ALTER TABLE public.metafinanceira ALTER COLUMN id_meta DROP DEFAULT;
       public               postgres    false    227    228    228            S           2604    16478    orcamento id_orcamento    DEFAULT     �   ALTER TABLE ONLY public.orcamento ALTER COLUMN id_orcamento SET DEFAULT nextval('public.orcamento_id_orcamento_seq'::regclass);
 E   ALTER TABLE public.orcamento ALTER COLUMN id_orcamento DROP DEFAULT;
       public               postgres    false    225    226    226            R           2604    16458    transacao id_transacao    DEFAULT     �   ALTER TABLE ONLY public.transacao ALTER COLUMN id_transacao SET DEFAULT nextval('public.transacao_id_transacao_seq'::regclass);
 E   ALTER TABLE public.transacao ALTER COLUMN id_transacao DROP DEFAULT;
       public               postgres    false    223    224    224            N           2604    16428    usuario id_usuario    DEFAULT     x   ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);
 A   ALTER TABLE public.usuario ALTER COLUMN id_usuario DROP DEFAULT;
       public               postgres    false    218    217    218                      0    16447 	   categoria 
   TABLE DATA           =   COPY public.categoria (id_categoria, nome, tipo) FROM stdin;
    public               postgres    false    222   �e                 0    16434    conta 
   TABLE DATA           \   COPY public.conta (id_conta, id_usuario, nome_banco, tipo_conta, saldo_inicial) FROM stdin;
    public               postgres    false    220   �i                 0    16534    lembrete_financeiro 
   TABLE DATA           �   COPY public.lembrete_financeiro (id_lembrete, id_usuario, titulo, descricao, data_lembrete, recorrente, frequencia) FROM stdin;
    public               postgres    false    233   �o                 0    16493    metafinanceira 
   TABLE DATA           `   COPY public.metafinanceira (id_meta, id_usuario, nome, valor_objetivo, data_limite) FROM stdin;
    public               postgres    false    228   Mr                 0    16475 	   orcamento 
   TABLE DATA           c   COPY public.orcamento (id_orcamento, id_usuario, id_categoria, mes, ano, valor_limite) FROM stdin;
    public               postgres    false    226   �x                 0    16504    parcela 
   TABLE DATA           Z   COPY public.parcela (id_transacao, n_parcela, valor_parcela, data_vencimento) FROM stdin;
    public               postgres    false    229   �|                 0    16455 	   transacao 
   TABLE DATA           g   COPY public.transacao (id_transacao, id_conta, id_categoria, data, valor, descricao, tipo) FROM stdin;
    public               postgres    false    224   R�                 0    16425    usuario 
   TABLE DATA           A   COPY public.usuario (id_usuario, nome, email, senha) FROM stdin;
    public               postgres    false    218   ��       *           0    0    categoria_id_categoria_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.categoria_id_categoria_seq', 100, true);
          public               postgres    false    221            +           0    0    conta_id_conta_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.conta_id_conta_seq', 100, true);
          public               postgres    false    219            ,           0    0 #   lembrete_financeiro_id_lembrete_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.lembrete_financeiro_id_lembrete_seq', 25, true);
          public               postgres    false    232            -           0    0    metafinanceira_id_meta_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.metafinanceira_id_meta_seq', 100, true);
          public               postgres    false    227            .           0    0    orcamento_id_orcamento_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.orcamento_id_orcamento_seq', 100, true);
          public               postgres    false    225            /           0    0    transacao_id_transacao_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.transacao_id_transacao_seq', 100, true);
          public               postgres    false    223            0           0    0    usuario_id_usuario_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 100, true);
          public               postgres    false    217            b           2606    16453    categoria categoria_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_categoria);
 B   ALTER TABLE ONLY public.categoria DROP CONSTRAINT categoria_pkey;
       public                 postgres    false    222            `           2606    16440    conta conta_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.conta
    ADD CONSTRAINT conta_pkey PRIMARY KEY (id_conta);
 :   ALTER TABLE ONLY public.conta DROP CONSTRAINT conta_pkey;
       public                 postgres    false    220            o           2606    16543 ,   lembrete_financeiro lembrete_financeiro_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.lembrete_financeiro
    ADD CONSTRAINT lembrete_financeiro_pkey PRIMARY KEY (id_lembrete);
 V   ALTER TABLE ONLY public.lembrete_financeiro DROP CONSTRAINT lembrete_financeiro_pkey;
       public                 postgres    false    233            k           2606    16498 "   metafinanceira metafinanceira_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.metafinanceira
    ADD CONSTRAINT metafinanceira_pkey PRIMARY KEY (id_meta);
 L   ALTER TABLE ONLY public.metafinanceira DROP CONSTRAINT metafinanceira_pkey;
       public                 postgres    false    228            i           2606    16481    orcamento orcamento_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.orcamento
    ADD CONSTRAINT orcamento_pkey PRIMARY KEY (id_orcamento);
 B   ALTER TABLE ONLY public.orcamento DROP CONSTRAINT orcamento_pkey;
       public                 postgres    false    226            m           2606    16508    parcela parcela_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.parcela
    ADD CONSTRAINT parcela_pkey PRIMARY KEY (id_transacao, n_parcela);
 >   ALTER TABLE ONLY public.parcela DROP CONSTRAINT parcela_pkey;
       public                 postgres    false    229    229            g           2606    16463    transacao transacao_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT transacao_pkey PRIMARY KEY (id_transacao);
 B   ALTER TABLE ONLY public.transacao DROP CONSTRAINT transacao_pkey;
       public                 postgres    false    224            \           2606    16432    usuario usuario_email_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);
 C   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_email_key;
       public                 postgres    false    218            ^           2606    16430    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public                 postgres    false    218            c           1259    16532    idx_transacao_conta_data    INDEX     X   CREATE INDEX idx_transacao_conta_data ON public.transacao USING btree (id_conta, data);
 ,   DROP INDEX public.idx_transacao_conta_data;
       public                 postgres    false    224    224            d           1259    16530    idx_transacao_data    INDEX     H   CREATE INDEX idx_transacao_data ON public.transacao USING btree (data);
 &   DROP INDEX public.idx_transacao_data;
       public                 postgres    false    224            e           1259    16531    idx_transacao_id_categoria    INDEX     X   CREATE INDEX idx_transacao_id_categoria ON public.transacao USING btree (id_categoria);
 .   DROP INDEX public.idx_transacao_id_categoria;
       public                 postgres    false    224            y           2620    16529 &   categoria trg_prevent_categoria_delete    TRIGGER     �   CREATE TRIGGER trg_prevent_categoria_delete BEFORE DELETE ON public.categoria FOR EACH ROW EXECUTE FUNCTION public.fn_prevent_categoria_delete();
 ?   DROP TRIGGER trg_prevent_categoria_delete ON public.categoria;
       public               postgres    false    222    236            x           2620    16527 #   conta trg_update_ultima_atualizacao    TRIGGER     �   CREATE TRIGGER trg_update_ultima_atualizacao BEFORE UPDATE ON public.conta FOR EACH ROW EXECUTE FUNCTION public.fn_update_ultima_atualizacao();
 <   DROP TRIGGER trg_update_ultima_atualizacao ON public.conta;
       public               postgres    false    220    235            z           2620    16525    transacao trg_valor_positivo    TRIGGER     �   CREATE TRIGGER trg_valor_positivo BEFORE INSERT OR UPDATE ON public.transacao FOR EACH ROW EXECUTE FUNCTION public.fn_valor_positivo();
 5   DROP TRIGGER trg_valor_positivo ON public.transacao;
       public               postgres    false    224    234            p           2606    16441    conta conta_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.conta
    ADD CONSTRAINT conta_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.conta DROP CONSTRAINT conta_id_usuario_fkey;
       public               postgres    false    4702    220    218            w           2606    16544 7   lembrete_financeiro lembrete_financeiro_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.lembrete_financeiro
    ADD CONSTRAINT lembrete_financeiro_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 a   ALTER TABLE ONLY public.lembrete_financeiro DROP CONSTRAINT lembrete_financeiro_id_usuario_fkey;
       public               postgres    false    233    4702    218            u           2606    16499 -   metafinanceira metafinanceira_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.metafinanceira
    ADD CONSTRAINT metafinanceira_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.metafinanceira DROP CONSTRAINT metafinanceira_id_usuario_fkey;
       public               postgres    false    228    4702    218            s           2606    16487 %   orcamento orcamento_id_categoria_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orcamento
    ADD CONSTRAINT orcamento_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria);
 O   ALTER TABLE ONLY public.orcamento DROP CONSTRAINT orcamento_id_categoria_fkey;
       public               postgres    false    222    4706    226            t           2606    16482 #   orcamento orcamento_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orcamento
    ADD CONSTRAINT orcamento_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.orcamento DROP CONSTRAINT orcamento_id_usuario_fkey;
       public               postgres    false    226    218    4702            v           2606    16509 !   parcela parcela_id_transacao_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.parcela
    ADD CONSTRAINT parcela_id_transacao_fkey FOREIGN KEY (id_transacao) REFERENCES public.transacao(id_transacao) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.parcela DROP CONSTRAINT parcela_id_transacao_fkey;
       public               postgres    false    229    4711    224            q           2606    16469 %   transacao transacao_id_categoria_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT transacao_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria);
 O   ALTER TABLE ONLY public.transacao DROP CONSTRAINT transacao_id_categoria_fkey;
       public               postgres    false    224    222    4706            r           2606    16464 !   transacao transacao_id_conta_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT transacao_id_conta_fkey FOREIGN KEY (id_conta) REFERENCES public.conta(id_conta) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.transacao DROP CONSTRAINT transacao_id_conta_fkey;
       public               postgres    false    224    4704    220               �  x�mV�r7>�O�OБ���,���������l�rI��nn}M�tƷ��c��
J�9=�G� >| v�BM;+XlQzq�¥ETB�x�2��[t^��qG<�;��k��#�����;�ֲ��I��9�W�k�{��7j�GT�=�l��� _��ޏފ�kB�ќ^���0С۠��VVh�1�cD3�1VtRD(�e7���bqz�i	���T�0Æ���'p�h�r�j"���A�����=���հ1�s�.����#��
~4:F�T^�V��X	���Ib���q�v@ۊ.��p)�0�Z�Y�Pa�� 9��d�@�zt�bD�9�=z�{�����D�2K��~��o���ȝ��2�<h����u�Z	?��Z�K��j�L�R�j�3�љ5�T�����-{2��J<�ϩ�B1�|�(z��ևd�)�G'}�.�`��c9�P��Ȓ���y+[vX��i�/�fݙazҒ=Z�u�P�r�t��硒D{8� %K�l��b��ǓbFj�]/YZrT�e^����6b�� �0$;25�_,��m\�V�ȼҹ�9PTpNUR���Z>����$��Y�k/<{��c0Ԓ	͉�P�b�eJr��B}�bI;��ˀ<�9\��[��E��մ{�(�Ú���
�S�y�˚�JH�ܢsFH榁��8����?�_㕊��z�|1��V��/YsUT4=d�"�x��L�&"y_��.�$�k���J8�R�2b��*n�֧����B8�
��E�!3�g�<'�m�������)��vk�l�P�%���Eu�cN�`�?���Im��cr���F	U'K�=�K��uuZ�Wˠ�a�=8��TRXFZ�����k����c�\�>���s�^}��)%�
�ݨN�q����H^u�ޙ��y��d��)�|�g�%ZӶ�Æπ�b2�����DDM��PZ�O�o���w���X�����ȥ|�7~�����_�/�         �  x�mWKn�6]O��o�\:�q��v�U6�0#�nj��:Y�A�by��%J�;�d��W�S��n��{k��۷m#�?�6��?b�ga�y�i�]�۶�j=��u�R��!�f��?}o6�l�>W��KAZ��������~�(�$=�����Z2>*i����ߚ�����4Q0�@�K�b��"�t�Ͳޔ�� "%B�w�[3_��4F$��������{~o���<�z5���L,�"��A��G��PeZS
t�<o�	U8���@�_�9ɠ���]>�z8|T�ʺ�����/��`��oО��~<-[k�t(�)y�w�Ѿ��~�nn���}u�	/�y�l����-��=|��oVIK煎,�w����G�~����(iz�C�����3�;a��~������J�/ۀ.��VMNS���92kz�|�ֱt��y�����^� �E��"j"+'�ƍ�}y��C�M&���	7�d�g	4a�̉s�Ͱ���(��u��
�Ba�PZw��Zl.Y/�&f���{�a]�w�2��{NH�w{��8%,�.���V���i~+[����Gfn���Z\>B^����};>sE�|9��
�fȲ�"h�5}:4�Y����x��wOm���SC���'��(���|�yU  ����.�����/�t�Vؔ�}صgg���^8R���Xr��=1yR��m��L6�ʃ�:)+]��Y�����ʍG�l�8�m�o�F�`�|i�O�K�}���j�p2�(Z�>�P�C���3X�A�p�����������p����#"����/���u�h�a� p�o���/��%+��F��sW��jt�*�7���zUm@�)�"D'9d�Tv�8dU���IU#o.؛�ZI�3}��)�+=�X��31�]��b'+��(XL����Q���9�|$��][`^���I�'
��ʣ�,���R;���u����Z��;��g&���^LUQ^�%�kʶ�{�;�b�n;Hq���<�ňҳj�q�c��,3���Q�	��O]��O��M3���%�9��y�0sс9X�����#SV��F2x4���m�o�ԑ�N�� �V�%�8� ��L	�6V���*'�7tq$�jK��3�B��s�x�.�z`B�3d=����I�+.�j�mc.�9n���|,�Z���l[wH�nW���VY-�BL�c�\�ޤ\IQc|s~1�D�z��^�D*��[N��R0���S؞��g�V��Ї
1l�9h�}�<����+]�{8-��wi
���['vD�x���/����g�e�Z�l8B�Z:
(
��כߚ�k��ɞ����i��eR��29�� ֊=g-e�AKS���eLC%���m��i����V>7��qF~5�9S�ED6��w��-��)	̒�Ϧo�T"����ym��B�)��u�w׬��+�O"|0(U�[f�j�xɋ����         �  x�}T�n�0�������ߌ���4hҢC��tv�R�@RFڭ�d(2d��U/�#%KJ�v�x����]�,Um+Tl�|yn8�`=��ab,f��|4N�gdr�A�'�+�;#����u��9��֏������2�L�`�P�5�p[Y�f��]6g�ĎvX?e�ڷ��1%��ɔM��hW)��3`�[̾���Iц-F�m��y2��~��s��2��}���Dc�T��T��u0�qcΦc']ľpeM���Y��2x;L1k:YP�����eyj
���>��]�Ϊ���:�E�xDX��
z��>;�e�L�&�T{�=�P��@ek���Qg�#��'����8���L���3��&F4rj�
6cg2�Yہt4�psc�|�l%���O3�4]���9�$����u�`:@0%���o��c+�n��\T2u1e���r��!�AȜ�ת���Q��c�ΙAX:z� �'()��4��aqc�c�;S��˥m�t�����בֿ�/�$]�0�K�.�ݖQHi4tLW�y藍*Z��R:
c �甭+�7ZI��mk����K%��>5
"O��G�eaػ��o�SAWW_xi���K$#V�;�2bBT��]���K�"��[��Y�`#�AEDTn��I�V���vH"h��@�+�'��>���P�H��{w�&I�?N��(         I  x�]Vˎ�F<���3=���V��_�)������ ��jrHz�Bͫ����-������N�L��N;v�+���m���N��S�aڐ����TԁJ�Y[3�vg��]��?Ǟ�e��mg��D(����]O���tu��lU$|?<SH%���%��A%\���X�N�]�g�ʔ=}>�#[�шqy�Yʉn��z���r(V3���+��ޜ�������:�u'e-Ꮿx�r���y���H��hܱQ� =\?�?���ӱ6~{+*�0}�K$�1�ں���`Q��?�{��s��������O������Sp.�Z�y�Eو���)Đ�Ok�d1Qɴ�ڵ5D	-�k��0ZSt1�RFX�䇡;�$TR��=`v��5X�[���8�3� �ӭ�9�o(��`\(m�<2��졾'�Q��pr�7�p�(�h5�e��)�vCwz�(.��:�PV��Z'f���/g�5��'��\�rM��o�Ǹ],�P����
�@ka�h��_��JJ�,���3ڽ= �`8�i�vM9K���FĬ��$�1(����Y8�Zm�����<tS�u�"Y�<�h�X����۽�lJԜW3 ��'�+���f%����i�rIܔ9�&�`^N�͆^�=�AD"���2(�~I��/�:q�1)o =����"�4�

u.�>��~��^�q�7�����}���:�-�  i��j请K=T0|/!��N��*{�g�	'����- U�ެX�.�
�۟o��3:�fV�7D���"�a%� ��⫌l,+[����"���k������̈́m�~sw��q,��qD�9&��⌓!���?^��]�fKx����.:p�r�
����^�cs��n����
�����I�N�H ����To�zD�%����PF|�?W�dL�ȯP�-�`RC�nK�E�_�
k���x;��,���w����H����ósG�;xPM¶CA���F�ɿ�~�Q�+O���-P<�/r�9�����!�����b`
�E6i:NV�qD�]�I��Jp ���[�\�N�rc���yLp�W��SÒ��9�f�1{Z�ł~� C� ��\�}�:�c2pyz;�O0v4W��=������Y��ǕƌE���*��Lhz�����&���� �E�2��}/��u_=
�X����5�!M���FP,F��RE��M_0شM%%�3�i֣1$^�S-����}�ϳ�����k?�Oq���v��F2�<x`mKA����o�d��0�����P�u��٭%��������lmiE�M?��\c��E7'D�h�E((6�*��	���EFe`����H��$$ƄvA{��2o3Z�q!ON�p8���t��< G�"HerێXzZX(��J6��]'M	�w�kON�A1pΧ^:R����F�����"o�Δ�X��w����}8��P��[��6N�	v���l���
QE��z p��m��p d�����<�4��U�Qd?��"�|0�e�{`)�1��˴��i���(�7ې倸�U30���R�?m۲�           x�MV[�%!���x�{���c�U����C)BH¥Q6�F�,�)i�M>�=Qe^�SF���DKt�J���{�+u�?���y�*��	�=��Yrƨ#�䒺Df�܃�Yq:���I��I3��iw���bx-�I�M�=��[���DT]�>��-B\�}�O�Ҡ����6�=�U��>2Do1��Ki��a�v
��F:��<�"Y��Pz'�.N\|����AOW(߶.��@�ߔ\�gx�$��=�Gq�햶�2������S���j*��D|����v_���~�c(U!�d�~}y�)36���	����g��-eٞ��S?�w*V�|�ILV�o<y��R\�Ռ}�[�U�Y��q�e��6`&�MB�[�$8#��*�V �#��ɷ��YS���A���́w�þ�L�� ��Q�MݍM�3Z�*K&��~.C�EJ�+���k�t��/?WA�>�ۭ���^L�5��7�l)�WS$/��n�x4(?��__��|xy�:��h��<,�)v'Izh*c�&�>-��W�������qq[(`�h�-�r��z��	�Bd�<v�
EY�sF��/j�M5�\I�ό�J� F�����q��x�kj��c#�#[+1&���C����t>��G�6*�i��z+B"+'��~ ��<�y�'����f�ͳ_����� ����1,��I�s{�ǫ���
�o��Ǩ|4yꏉ�[]�s��#<V��9�Ŋ8�Y�<����Ĉ�o��q6����a�J#�_z�!�Nt{��'���do8��g�\�0��?�Tgd�j�ӕ�c�8��U�X�g�
��P�����X`��L���ظ��[���M�`����I�ӛ�����1��v��۫���X����pjb��ճ�z�߆Q����P?���=;r��V=Ƌ���h���? �.T/�?/a%5���s|�W�U1{�7�/�����������J�Q�^��ل������093�j��tɏ�u�-	��ZϜ�֜�?w�{S         ~  x�]ZI�$9[g�%�ـ�����Q�<��eQ�= g��Yj�X2�������S�cAc�R���?M�ɍ�Bk���'�=M�/a���x��O�/�{��i���^�a���unV��������{<������~ZF����s����)��:W��^�3��꺅�z}FZ�u.[p+��>�u��8���eߊusº�z!`ŕ3<f��V�&�~���xO]�؏�O��Z��`��ў����_�o��z^�^,7Xq1�����5V���'���q�~����x\��v3�#��)q/v� ���Jq������!wX��>yw}�F{b�o����)��r�k#�����Ç�Жu.[`��==}��"�����iq6��rb���3�L�_iF(�/��3n�A:��J�e�'��@�/�@�yi�cS�ci��̱̝�c�`8�� ����<�"pG&^rGV��U�y`<��.rȠ��I�OpJ�) �y\��:����d�e�qD�'�u���2�W�wKܒ����0����P�+��Ћ�5�;���3��5<�B����a'��n���d��(�g�f;ғơ  -��k7�Z�gG,=?ƹG���I����'�:���1ozq������H�kކ講u&�5Z���V�i��D�e��F�D��6jMf|��z��h�<�'`���6��O�z�����&f�����v����R��k�<	NH;�Y5��ˎ�0��S��>p��Ae.����hA��F@:6���3!2ťG�Ʉ� 9�kF�#"�Pm�]10!�P^���L����?k��7og�&P�����t�&�B�3��A�9n��6��J�_Vb��R�y�8h&��r���3����/V|�(b�q�oĩ#6�s�T#���N$Q`�@%��������o=�
p]�\�Z��Av��u
�X;�S)�*�G���\;	�I�N�� 	*���]RD����5y�fxٳ���0�ܘVb̪?�ݓȌE��Y!&��0LQ�K���	�N+�O�M�EK��]��ˌ[\��
���B��vEA��E(K:Q�ٓT�p)i�e�Kʉ�NPJ��;��e�v���4��0�`$���oodW��P:�� ���Y[_��3nS��-bh�JiX���j�ff7��.�r���%�od ���sKd�O!�N�PT��G�m����N$8�N��۹9��]E��B6�ThV�X�ab�hF���]#=D;u	_���t����p�!��;DR\Z���>� �s]��^�ed�f�ѫ���K*�]ۧS3�T*�I�q�$��*����'��m�h[�ë��n�i
A[�K/�(�#[Ӿ��/�I�ƕz����@�.
��8+p��y�|��7�Ӵ4��*���?򪞛�+�l-��rUf��~�!]%�[�U�E!����baDBH�f�T?�A��0ǺΤ�J3��sm����y�̄��Gb���o�������3��.���
���(��a�ĭ�'i����S�4}�E�mvV	=UR�H�Aa�����4cmp�m�f�[�S��8.MTZ��D%AT�9���5X�n�g��`����|`�i��k��O��ch�����,�Z1i��<e�ju�A���*i>T��ͭ|&�I�[���&����v7`������J3+_��Ӊ� �Tlo�UUѲ�Nz�UUq��RH2�p:��Ү@_�ҁ�6��$�c�Rv��6s���']}�	VU�/�s��u�F�D.)*�X;�� �D^Ur��Wp:!Q�;
�+�%��3�O��l�K��ݗI��}��tuq@vQ��7��IO��T�+�q"�!�F��X8H]�*���%ְ�<Ub�Z��eE��;$�mJ��S�J!�E��6�R����%��N3AcvNb:w�@��C���-}�t˶�'w���1:���"h��Zi����L�U��"&�\źa�6t	s�]@����iW��TwR4;_��`k R����Va�s��r��7Du;���_���rp�������������A�lk�����4ni�ӷ���Ԇl/�����Ai�^RKP�۶@K�3�tS{��$� ���	���m�݉%�ZYA��q��Zg���������wZ��ګ+�4��҂�n�kL�ի���9�lR}Ǳ�5�:e\U�jt��«5�4〽��&�����Q�ݱ
\� ő�o!�H�A,��6�M���h`[�1[ZO�i��ˮ��u��R^�̮�U�`����*����6(����	<`q���9`�"p4L����$��z.� ��L4s��WA���.}���e��:����.�|^�XYx"�r�+1�uƷ%��R�N�$��TuO[�y�t��̱u=s��hf�����k�f�! <�?T��R��`�/; ���䨿�4Ϣp�J�&���W� 3�Ǥ:JR"����k�"k��Poe� �%V������Y���Y}���}�[�k�uޑ%/o�6�o��\��o����94R�i4
�����p���:�AfvWhL��ʚ�Z;��_Iࣺ�N����$5�|�I�ܑ�&�d�q.Õՙ��[}h��TS��}$���p������\�Y�.�X��M����Ү׉Z��Ֆ�;�d���)�Y뫧�=]��	����;JBqo3�P��� �ݯ˷��)ޙ�U���/Qزk��Q�3(���Z��Hd��n����j�淄�ݮ�3��i�_�a]Cc[^ʺ�쓍�ݱ���A/_s�1��3����i��S��#��e�&��G����ta��_uD�	{�Ÿ$`������AȐ�ǁz	�j��z*4�'b�vz�e)��`������~��a��X
����~�0样�������U�v�gm�%��%�g��U���=��Y��R��w7�Itv�3T��~�%U�s����TT���CXˌM9��#F�OsT 2�97�זK��to*p}��f��Cs�s���PBk��O|	Jh\�oi"��앫l��H���Z1�J�`���[sԮYly�)��'�g^:_�^ q��z{���ۜ�_����X�Gꮒϡ��Sj�%��P�!t�5؂l�ː*�c�k�Zi6QZ���E���ְ8V����z_tiK�W�F�s��W����8��q{�Dd6�Ԕ��R�Ξ8��i�����V���yh8x�g01���i���2�d�>kl��2�:R��g~�	� ed��x�V@����%}�C���?��Q�������������6Tj��©�̐�;�V��Y%�{����*����9�̷5N:��- F��|D����sKΫ�m������q��rI��X�^�$�RP@w�D*�P yy9V��08,���0�R�,n�yU��ϸ��pE�Q���V����}�T�͈�~QK�_
�}�{���?�H�         Q  x�mYݎ�6�V��/���k�r�l� _ӟ����v�dl}�lM �.6+�"9R�V8/T���TOZ
零VN����{5��v�ƭZ�e��]���uk�m����8m�%��D�z�N(glZ��2��t[�j�ΰ����6��-��N٧��r���u���<�j��鲯�0��2mS���׽������!��W^ؠk��o���x�aZ��u�q�����u���u�j�CV�^��I�E�j�������N\?}��	�	���p���u�_�p8��!��A8�6���9���NE[!�F�hp��'^׍o��:�۸�GF�������qF�
y�W�f�p�-鑍Cz���;���X��hv�<5�^����mğ��k�O]?�0p��|R�SȬ}R��iS[#~����s�(�g$��R*b�Ԧq5"���뻍r�:v[7��4���Kw/�I�k�����!�#�ԍ|�<_�[�����YDjr.�<>K{�l�/��e�� �8=�8�)����4� � ����<:4M��?wH=�?<�
���U�dZ!�w��HfW��
����K��s�0�P� ^��b�����$[�)��8�l�m�׼�{�[.��6w�X2�d�mGQV;Bӯ��F9P�ǁ�mO�@�L+kc����;�x.!)�)`�$�&D.��i���׭g>Cʷi���|�o '�0#	R2�^6�2����:��O\goF
*xZXqja������[�E<� ��6��Ŷ&�8�jaZ�lzT�w�>�" <G��CV��}�,�Z�H\H�̈́����|p�_���p.F2��4��	���`P�P�5��j�^��u%@uΡ�.����	kϢ���i�T���H���@B��w�Oe���_�	���mZ��	�'ډ�Q\OUw�?��E]\R��	��L��.�~a!��K��N��y�#�p�ZX��F&A2���6���1R�h����%�������D���y�LTU��c��'�:6$ՎM�N��H_k�����8cEt��%.����x�KU�Q8��Y\��{��L����4j^c�P�ݗ��Pv� �ņ�4���k�4�F���@�B����RD[�K�?�`��Ҋw����5(��B�7>6���9ݐ��l[�U/ϴ�)�p%�&`{��VmS{4�+�|3��$��}���gk�Y������*+��&���� �ۈ�!V�S��h[�j'��+$�}����-�:�˅1~ ����~G�G�[#�6$ѝ�~�'ЈR�Td%�c	�؇�[���p�'��	�PJ�)��W��J:�8��(M�2��&�lc���2���n��S
5e�P��pz^	1���z�\f��فt�mbqw��9KO�8u{v}�W��G�E����	�jVc@�A�Eq�繋r�u=�8�
���J07�-��덻]��"�1&F�
ȓ̰�x��R�H��#�����=���%�t.+�ZƇh�3��g�E ,@�����Ł�5����,�}�uL��'V�����J��tO��YI/݉��<%�|	@�ʼ}bf��IhhH`�����R�* <գ�FgZ��_S�s;��<ߓ�a�]-b�EE��M?O�R���ne3��� Z����!T*I����}w������q��b� �<C�п4	<�������~��,� �=�n:���I�cC�|;�vL�4�V<	�6�!��6�xȳD���eZ�Kwȝ���6$�pF��Ì�(ms��yd]��2[�a~u�ZF�`L��}�yՕ��qS�d�ӭȳmY��N`������0�4W�y���1���90AGMVܩ�'�9[&��wB=?�E��q'Nؤ��L�fU��kb�׉�uh��Fp��\C�E�?gVK,���/��_i���⁸0�!'�Kq��ʣF|~�ވ�aZx���}�""��"�m�uO�OŦ����/c��Ӝ�\����bp!��9ͫ@�y���*���$:N�:{��H%$.fhM��S@r�%a:-e:[���&�zF��1���}��@�-KG�b���ПJ�1R���|��!F��x �CH��k/��12�I ���5Ϲ���!�?P����8���
���!珝�Z�!y�7�wjLl2�q���Q�p���y�A�i��7 �G��6K於5��5�߻<�}C��c{������S��6���_�
�?ć٪&��hy6��8��]���V��E�4�@o��d�6J~��+d�1p�/�:L��n衒�DPU�K,h:iH�FM�ŭ�4�*?M;���s�)�]�gZ���`�-�b_.5���;*⺔�3E�+�EhK p�Ϳ6�]J3�j��;'����{��[FH(��x@�������,o��[z�v�\� c��Y>~�D���_���4P��h�ż���X/k��WĲ�_�r��yg��1/��	\K�1�dO�~@�z���I�eE�K$`�g��
�`*C%*���?k!>e{��j�
3�[2�S���Q�6�K�R[4Z�������/]>??ZY����󒄊"rYW�q���T
�c5+�x�%9K�P><��a(K�:��A�AWg�"�&�!��-m>�-���&��O]J*�Eٌ��Bi������
9��a�P�'�ifp3%���z0��"�<��T�>�q<�=s1<�]��Tq����<}����
?�"��e}�q�����-���~�*ơLé`Ӓ����*�)+��Z\'��)\H[�����
3�G2���| ���u+(T�j0/K�˖�V���Z�&���9�z>�.��@���k�cl����߼y�п�v         y  x�mX�r��\w��&�C�'�< ��F�-�AB������z������n	���MUgfee#��/S�t�Fs��$�i��'�\���8�����KC�P���T�XA����t�Ş�ЩOT�qi�"����>9��5�`��/�����ه��̾��( iL$�	���F�
����Z+|<���:|�+��x�O]��$\�ęޓ��j>�5L��ALNKW!�R/H�7��	܆F�组:c�o�z��n�~�;*6�YDJ�Y�����?!(͊mɜ��T])�����h�M�SmB�ҭ����`�P)�2*��aݞ�g�B}:��-u���3�	��*���\��_��U�f��
��FWю�Zd�^Pj���� ��M~y���*����X��c���_�',K�^����~5#�������5���d�n/�y�{v�,����t�˔�D������9����	#�Q�$cez�Y��2���d^��pA�/��O"�ur�Ni<C=ͽ|y|Y��XVQ+�i�Gc�nɌ.X�΂�c�����=��X�йO"�q GV�1&��rm�����?o����h �$���N�#vF?pR�6����^Ų��܋C�Ԣ!t�Ep�q�Di� ���×\
�*X6Q7)�8��>ua��d&i��%\_�T
�:�-8B��|0A�	!nDׄ!��\�� �a�F
39�)BLt@�pL�P+..��ި����:Ɗ���Oc��O\j�N���h�qv��������V@>@ZIv����&\㤩=�qh}`E���@ws�vc��3��d	h�j���:�w�
�@> m��3�e�����R��=��l����>��e� ��!L��&�Rt��F�n@!Vt���~�NH>�$vA�KgNW�{���1�ӣ�05`E׉������i�0ӌ�v�|z�.����`T��9W-g�G���g�Q������Zi\�1Q$��D���T�xTՇM0ɑ���m���+�A�2�Ã�h�WǦg��J0ǠG�~�e>R�Q6ׇ��%��rA�F*Ve �AIt�a���P(J�Gt�M�vIM��EU�*Þ �4 ����I :�5��9����u�|2�:��ܺ.}oV��Lh�Ƀ��� |('���U�P��k���e��N`�q�9j�����Ic�U�߿����i�2b�8��ҕEٺ��Lj�H�,�6KМfr�1^�h���z��Xª��ȷ�'�U����`3����B�ڣ�$ױjv���ʻ#��NZ�����Ѽ�b���=�[q^�Y+1_s)Lg��
��Mz���IY�IދV�`,v�ag�jtRW�&���[b��}��2aVt cEj����aE"?j���n��5ǟ��Ȏ��'�G���?tZ�X�|N_ƍ�kڿc!��o���A(9XUJk]���ǚ.�����E�qD:a�_OjŻ��^c�@bfh�/�m�ڄ���U�Fy�5�Y�Ś	�o��F��4�	�ɛu�̞>�7c����VB���Q�"$u�E;�gc�-�u�L� "i�eXo[�&]]\��
�%$.ߣъ�9�Ă�-�Sk~k��gU�a]ރ V(b�e�-fn�^;R3�t� ��8C!�	�G�WXh��d��'�������Yr� �q�/�'�-�����u-[�MnD��!�-CFZ��}��ak;Ө�º�G���wSK+rT?;yW:���빙P���?������22�a��l�:�M!�� 6�H.ܬq�5����`��[�f���GRP�u�$.�-��HA��u=1;-�S�i@	�G^`oIt��~{Z�mI�ڥ������3}�΂�N2z�$	�2��LBY�9�A�F���L?��@���l��8�bpZG�s]}\�"l����߿#���-��s�}�t:ۧYN��Ie�7�KV��^���e��IM��n��{߃�C�P�"�v��W��}�2Ć��sj��D�	���)EZ4_n�g��s�H>B�E:�]W���l䱶Ǖ�����"x���wp'�o�Ɏ�U���T���� �ֳ�iIŊG��r�w�6���{�C^�/Nh����Ν׻��ut���)q6�B�t�A��B��7o��
g,�^��ɄyLqᙵ�d�J�R1UީkxE�<��o�3���';l�M|�S��Y~�����v�<\��%=��S�Xx\�]�zc5F7�W�����Ʀ�Yў�I��y���y{��8���4E���!�\8^�x4���`)=a�B�{f��G�0+U,б����]�¦� �ivM/�30_��?�\���7�]����5=��%����l��2��~B�k�b���Lǖ�Ι�0���w%���	e^����|�}��O�LY�6�bw��x�j�馆-N��4�?��ޔ��dy@��E�G:i|aKC}�h�
�-��}|���^��Ӗ�t���~lĉa���@	�W�Ol�4��/b�x33Y�+Ej-�[f�
��O����O���$���[k�F�0���|�t��g1����M��*&������?&ً������H�����ydÊx�4�_�� ���`^uf��&����`�- �l3_3���<���GR���kX�lz��SC�,���8<�WGZ��ol�BRM��ɑ���ӌ�t���{Tlk�=�]w��YR���A�^5vM������=���_��@�7f>vſ���}�Wαmv�%� 8Hw�k����R��,����	��Q�?&~��r~��d��}��F�m��z0K�_'�r�ªGU���L.�ul�hO�-�u����!�cZn�/S�e�Ɋ?��6!��K���{��YL����s�1��
4T     