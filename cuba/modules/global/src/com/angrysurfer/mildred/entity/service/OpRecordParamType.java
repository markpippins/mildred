package com.angrysurfer.mildred.entity.service;

import javax.persistence.Entity;
import javax.persistence.Table;
import com.haulmont.cuba.core.global.DesignSupport;
import javax.persistence.Column;
import com.haulmont.cuba.core.entity.BaseIntIdentityIdEntity;

@DesignSupport("{'imported':true}")
@Table(name = "op_record_param_type")
@Entity(name = "mildred$OpRecordParamType")
public class OpRecordParamType extends BaseIntIdentityIdEntity {
    private static final long serialVersionUID = 597175092119457297L;

    @Column(name = "vector_param_name", nullable = false, length = 128)
    protected String vectorParamName;

    public void setVectorParamName(String vectorParamName) {
        this.vectorParamName = vectorParamName;
    }

    public String getVectorParamName() {
        return vectorParamName;
    }


}